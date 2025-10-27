local function LoadReactions(addonname, file)
    gState.Triggers = T{};
    local paths = T{
        file,
        string.format('%s.lua', file),
        string.format('%sconfig/addons/ShinyReactor/%s', AshitaCore:GetInstallPath(), file),
        string.format('%sconfig/addons/ShinyReactor/%s.lua', AshitaCore:GetInstallPath(), file)
    };
    for _,path in ipairs(paths) do
        if (ashita.fs.exists(path)) then
            local success, loadError = loadfile(path);
            if not success then
                print(string.format('%s%s%s',
                    chat.header('Reaction'),
                    chat.error('Failed to load reaction file: '),
                    chat.color1(2, path)));
                return;
            end
        
            local result, output = pcall(success);
            if not result then
                print(string.format('%s%s%s',
                    chat.header('Reaction'),
                    chat.error('Failed to call reaction file: '),
                    chat.color1(2, path)));
                return;
            end

            if type(output) ~= 'table' then
                print(string.format('%s%s%s',
                    chat.header('Reaction'),
                    chat.error('Reaction file did not return a table: '),
                    chat.color1(2, path)));
                return;
            end

            for _,trigger in ipairs(output) do
                local newTrigger = {};
                
                if type(trigger.Abilities) == 'string' then
                    newTrigger.Abilities = T{ trigger.Abilities };
                elseif type(trigger.Abilities) == 'table' then
                    newTrigger.Abilities = T(trigger.Abilities);
                else
                    newTrigger.Abilities = T{};
                end
                
                if type(trigger.Spells) == 'string' then
                    newTrigger.Spells = T{ trigger.Spells };
                elseif type(trigger.Spells) == 'table' then
                    newTrigger.Spells = T(trigger.Spells);
                else
                    newTrigger.Spells = T{};
                end
                
                if type(trigger.Users) == 'string' then
                    newTrigger.Users = T{ trigger.Users };
                elseif type(trigger.Users) == 'table' then
                    newTrigger.Users = T(trigger.Users);
                else
                    newTrigger.Users = T{ '*' };
                end

                if type(trigger.Color) == "table" then
                    newTrigger.Color = trigger.Color;
                end

                if type(trigger.Reaction) == 'string' then
                    newTrigger.Reaction = trigger.Reaction;
                    if (trigger.MustTargetSelf) then
                        newTrigger.MustTargetSelf = true;
                    end
                    gState.Triggers:append(newTrigger);
                end

            end
            
            print(string.format('%s%s%s',
                chat.header('Reaction'),
                chat.message('Loaded reaction file.  Trigger Count:'),
                chat.color1(2, #gState.Triggers)));
            return;
        end
    end
    
    print(string.format('%s%s%s',
        chat.header('Reaction'),
        chat.error('Reaction file not found: '),
        chat.color1(2, file)));
end

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0) or (	(string.lower(args[1]) ~= '/shinyreactor') and 
							(string.lower(args[1]) ~= '/shinyreact') and 
							(string.lower(args[1]) ~= '/sreactor') and 
							(string.lower(args[1]) ~= '/sreact') and
							(string.lower(args[1]) ~= '/sr') )
							then
        return;
    end
    e.blocked = true;
	if (#args == 1) then
        gState.Active = not gState.Active;
            print(string.format('%s%s%s',
                chat.header('Reaction'),
                chat.message('Reactions: '),
                chat.color1(2, gState.Active and 'Enabled' or 'Disabled')));
	elseif (#args > 1) then
        if (string.lower(args[2]) == 'on') then
            gState.Active = true;
            print(string.format('%s%s%s',
                chat.header('Reaction'),
                chat.message('Reactions: '),
                chat.color1(2, 'Enabled')));
        elseif (string.lower(args[2]) == 'off') then
            gState.Active = false;
            print(string.format('%s%s%s',
                chat.header('Reaction'),
                chat.message('Reactions: '),
                chat.color1(2, 'Disabled')));
        elseif (string.lower(args[2]) == 'debug') then
            gState.Debug = not gState.Debug;
            print(string.format('%s%s%s',
                chat.header('Reaction'),
                chat.message('Debug Mode: '),
                chat.color1(2, gState.Debug and 'Enabled' or 'Disabled')));
        elseif (string.lower(args[2]) == 'load') then
			for index,c in pairs(appliedColors) do
				appliedColors[index] = nil;
			end
            if (type(args[3]) == 'string') then
                LoadReactions(addon.name, args[3]);
            end
        elseif ((string.lower(args[2]) == 'resetcolors' or string.lower(args[2]) == 'rc')) then
			for index,c in pairs(appliedColors) do
				appliedColors[index] = nil;
			end
            print(string.format('%s%s',
                chat.header('Reaction'),
                chat.message('Colors Reset.') ));
        end
    end    
end);