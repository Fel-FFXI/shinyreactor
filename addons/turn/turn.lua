addon.name      = 'Turn';
addon.author    = 'Thorny';
addon.version   = '1.00';
addon.desc      = 'Turns toward/away from things.';
addon.link      = 'https://github.com/ThornyFFXI/';

require('common');
local chat = require('chat');

--If you are less than [tolerance] degrees off of the heading you're trying to turn to, you won't be turned.
local tolerance = 10;

local function GetPosition(index)
    local ent = AshitaCore:GetMemoryManager():GetEntity();
    return { X=ent:GetLocalPositionX(index), Y=ent:GetLocalPositionY(index), Z=ent:GetLocalPositionZ(index), H=ent:GetLocalPositionYaw(index) };
end

local function GetPosHToFace(origin, target)
    local rads = math.atan2(target.X - origin.X, target.Y - origin.Y);
    local ffxirads = rads - (math.pi / 2);
    if (ffxirads > math.pi) then
        ffxirads = ffxirads - (2 * math.pi);
    elseif (ffxirads < (math.pi * -1)) then
        ffxirads = ffxirads + (2 * math.pi);
    end
    return ffxirads;
end

local function GetDegreesOffHeading(origin, targetHeading)
    local headingDifference = math.abs(targetHeading - origin.H);
    while (headingDifference > (math.pi * 2)) do
        headingDifference = headingDifference - (math.pi * 2);
    end
    if (headingDifference > math.pi) then
        headingDifference = (math.pi * 2) - headingDifference;
    end

    return (headingDifference / (math.pi * 2)) * 360;
end

local function SetHeading(heading)
    local myIndex = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
    local ptr = AshitaCore:GetMemoryManager():GetEntity():GetActorPointer(myIndex);
    ashita.memory.write_float(ptr + 72, heading);
end

local function TurnToward(index)
    local myIndex = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
    local myPosition = GetPosition(myIndex);
    local targetPosition = GetPosition(index);
    local targetHeading = GetPosHToFace(myPosition, targetPosition);
    local degreesOff = GetDegreesOffHeading(myPosition, targetHeading);
    if (degreesOff > tolerance) then
        SetHeading(targetHeading);
    end
end

local function TurnAwayFrom(index)
    local myIndex = AshitaCore:GetMemoryManager():GetParty():GetMemberTargetIndex(0);
    local myPosition = GetPosition(myIndex);
    local targetPosition = GetPosition(index);
    local targetHeading = GetPosHToFace(targetPosition, myPosition);
    local degreesOff = GetDegreesOffHeading(myPosition, targetHeading);
    if (degreesOff > tolerance) then
        SetHeading(targetHeading);
    end
end

local function GetTarget()
    local targetMgr = AshitaCore:GetMemoryManager():GetTarget();
    local target =  targetMgr:GetTargetIndex(targetMgr:GetIsSubTargetActive());
    if (target < 0x400) then
        if (bit.band(AshitaCore:GetMemoryManager():GetEntity():GetSpawnFlags(target), 0x10) ~= 0) then
            return target;
        end
    end

    return 0;
end

local function CheckEntity(index)
    local entity = AshitaCore:GetMemoryManager():GetEntity();
    if (entity:GetHPPercent(index) == 0) then
        return false;
    end
    if (bit.band(entity:GetRenderFlags0(index), 0x200) == 0) then
        return false;
    end
    if (bit.band(entity:GetSpawnFlags(index), 0xFF) ~= 0x10) then
        return false;
    end
    
    local claimId = entity:GetClaimStatus(index);
    if claimId == 0 then
        return true;
    end

    for i = 0,17 do
        local memberServerId = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(i);
        if (memberServerId == claimId) then
            return true;
        end
    end
    
    return false;
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if ((#args > 0) and (string.lower(args[1]) == '/turn')) then
        e.blocked = true;
        if (#args < 3) then
            print(chat.header('Turn') .. chat.error('Invalid syntax.  Correct syntax is: ') .. chat.color1(2, '/turn [toward|awayfrom] [index]'));
            return;
        end

		local index = 0;
		if (args[3] == '%t_index') then
			for i = 1,0x3FF do
				if CheckEntity(i) then
					index = i;
					break;
				end
			end
		else
			index = tonumber(args[3]);
			--Debug statements
			--print(chat.header('Turn') ..  ' Args3: ' .. args[3] );
			--Old statement:
			--print(chat.header('Turn') ..  tostring(AshitaCore:GetMemoryManager():GetEntity():GetServerId(index) == nil) );
		end
        --Debug statements
		--print(chat.header('Turn') .. 'after: ' .. tostring(index) );
        --print(chat.header('Turn') .. 'logic: ' .. tostring(AshitaCore:GetMemoryManager():GetEntity():GetServerId(index) == nil) );


        if (index == nil) or (AshitaCore:GetMemoryManager():GetEntity():GetServerId(index) == 0) then
            print(chat.header('Turn') .. chat.error('You must specify a valid target.'));
            return;
        end
		

        if (string.lower(args[2]) == 'toward') then
            TurnToward(index);
        elseif (string.lower(args[2]) == 'awayfrom') then
            TurnAwayFrom(index);
        else
            print(chat.header('Turn') .. chat.error('Invalid syntax.  Correct syntax is: ') .. chat.color1(2, '/turn [toward|awayfrom] [index]'));
            return;
        end
    end
end);