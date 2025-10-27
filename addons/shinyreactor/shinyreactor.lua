addon.name      = 'ShinyReactor';
addon.author    = 'Thorny, Fel';
addon.version   = '1.2';
addon.desc      = 'Monitors mob TP and spells and allows reactions to them.';
addon.link      = 'https://github.com/ThornyFFXI/';

require('common');
local d3d8 = require('d3d8');
chat = require('chat');
gState = {
    Active = true,
    Debug = false,
    Triggers = T{},
};
appliedColors = {}
require('commands');
require('packets');


--offset for entity model color (taken from the addon chamcham written by Atomos. 
--See https://github.com/AshitaXI/Ashita-v4beta/blob/main/addons/chamcham/chamcham.lua#L34 

local chamcham = {
    offset = 0x0660,
};

function rgba_table_to_string(color)
	if color == nil then
		return 'empty'
	else
		return string.format("%.3f, %.3f, %.3f, %.3f", color[1], color[2], color[3], color[4] or 1.0)
	end
end



function HandleAbility(index, name, targets)
	local e = GetEntity(index)
    local user = e.Name;
    --local user = AshitaCore:GetMemoryManager():GetEntity():GetName(index);
    if type(name) == 'string' then
        name = name:trimend('\x00');
    end

    if (gState.Debug) then
        if name then
            print(string.format('%s%s%s%s%s',
            chat.header('Reaction'),
            chat.message('Ability detected.  User: '),
            chat.color1(2, AshitaCore:GetMemoryManager():GetEntity():GetName(index)),
            chat.message(' Ability:'),
            chat.color1(2, name)));
        else
            print(string.format('%s%s%s%s%s',
            chat.header('Reaction'),
            chat.message('Ability detected.  User: '),
            chat.color1(2, AshitaCore:GetMemoryManager():GetEntity():GetName(index)),
            chat.message(' Ability:'),
            chat.color1(2, 'Unknown')));
            return;
        end
    end

    if (not gState.Active) then
        return;
    end

    local myId = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0);
    local userId = AshitaCore:GetMemoryManager():GetEntity():GetServerId(index);
    local targetId = targets[1];
    local targetsSelf = false;
    for _,target in ipairs(targets) do
        if (target == myId) then
            targetsSelf = true;
        end
    end

    for _,trigger in ipairs(gState.Triggers) do
        if trigger.Users:contains(user) or trigger.Users:contains('*') then
            if trigger.Abilities:contains(name) or trigger.Abilities:contains('*') then
                if (trigger.MustTargetSelf ~= true) or (targetsSelf) then
					if (trigger.Color ~= nil) then
						appliedColors[index] = trigger.Color;
					end
                    local output = trigger.Reaction:gsub('$action', name):gsub('$userindex', tostring(index)):gsub('$user', tostring(userId)):gsub('$target', tostring(targetId)):gsub('$me', tostring(myId));
                    AshitaCore:GetChatManager():QueueCommand(0, output);
                end
            end
        end
    end

end

function HandleSpell(index, spell, targets)
	local e = GetEntity(index)
    local user = e.Name;
    if (gState.Debug) then
        if spell then
            print(string.format('%s%s%s%s%s',
            chat.header('Reaction'),
            chat.message('Spell detected.  User:'),
            chat.color1(2, user),
            chat.message(' Spell:'),
            chat.color1(2, spell.Name[1])));
        else
            print(string.format('%s%s%s%s%s',
            chat.header('Reaction'),
            chat.message('Spell detected.  User:'),
            chat.color1(2, user),
            chat.message(' Spell:'),
            chat.color1(2, 'Unknown')));
            return;
        end
    end
    
    if (not gState.Active) then
        return;
    end

    local myId = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0);
    local userId = AshitaCore:GetMemoryManager():GetEntity():GetServerId(index);
    local targetId = targets[1];
    local targetsSelf = false;
    for _,target in ipairs(targets) do
        if (target == myId) then
            targetsSelf = true;
        end
    end

    for _,trigger in ipairs(gState.Triggers) do
        if trigger.Users:contains(user) or trigger.Users:contains('*') then
            if trigger.Spells:contains(spell.Name[1]) or trigger.Spells:contains('*') then
                if (trigger.MustTargetSelf ~= true) or (targetsSelf) then
                    local output = trigger.Reaction:gsub('$action', spell.Name[1]):gsub('$userindex', tostring(index)):gsub('$user', tostring(userId)):gsub('$target', tostring(targetId)):gsub('$me', tostring(myId));
					if (trigger.Color ~= nil) then
						appliedColors[index] = trigger.Color;
					end
                    AshitaCore:GetChatManager():QueueCommand(0, output);
                end
            end
        end
    end
end

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
	for index,c in pairs(appliedColors) do
		local e = GetEntity(index);
        if (e ~= nil and e.ActorPointer ~= 0) then
			ashita.memory.write_uint32(e.ActorPointer + chamcham.offset, d3d8.D3DCOLOR_COLORVALUE(c[3], c[2], c[1], c[4]));
		else
			--Shouldn't happen
			appliedColors[index]= nil;
		end
	end
end);
