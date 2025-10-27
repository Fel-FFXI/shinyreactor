local function ParseActionPacket(e)
    local PendingActionPacket = T{};
    local bitData = e.data_raw;
    local bitOffset = 40;
    local function UnpackBits(length)
        local value = ashita.bits.unpack_be(bitData, 0, bitOffset, length);
        bitOffset = bitOffset + length;
        return value;
    end
    PendingActionPacket.UserId = UnpackBits(32);
    local targetCount = UnpackBits(6);
    PendingActionPacket.Res = UnpackBits(4);
    PendingActionPacket.Type = UnpackBits(4);
    PendingActionPacket.Arg = UnpackBits(32);
    PendingActionPacket.Info = UnpackBits(32);

    PendingActionPacket.Targets = T{};
    for i = 1,targetCount do
        local target = T{};
        target.Id = UnpackBits(32);
        local actionCount = UnpackBits(4);
        target.Actions = T{};
        for j = 1,actionCount do
            local action = {};
            action.Reaction = UnpackBits(5);
            action.Animation = UnpackBits(12);
            action.SpecialEffect = UnpackBits(7);
            action.Knockback = UnpackBits(3);
            action.Param = UnpackBits(17);
            action.Message = UnpackBits(10);
            action.Flags = UnpackBits(31);

            local hasAdditionalEffect = (UnpackBits(1) == 1);
            if hasAdditionalEffect then
                local additionalEffect = {};
                additionalEffect.Damage = UnpackBits(10);
                additionalEffect.Param = UnpackBits(17);
                additionalEffect.Message = UnpackBits(10);
                action.AdditionalEffect = additionalEffect;
            end

            local hasSpikesEffect = (UnpackBits(1) == 1);
            if hasSpikesEffect then
                local spikesEffect = {};
                spikesEffect.Damage = UnpackBits(10);
                spikesEffect.Param = UnpackBits(14);
                spikesEffect.Message = UnpackBits(10);
                action.SpikesEffect = spikesEffect;
            end

            target.Actions:append(action);
        end
        PendingActionPacket.Targets:append(target);
    end

    return PendingActionPacket;
end

ashita.events.register('packet_in', 'packet_in_cb', function (e)
    if (e.id == 0x28) then
        local packet = ParseActionPacket(e);

        local index = bit.band(packet.UserId, 0x7FF);
        if (AshitaCore:GetMemoryManager():GetEntity():GetServerId(index) ~= packet.UserId) then
            index = nil;
            for i = 0x400,0x8FF do
                if (AshitaCore:GetMemoryManager():GetEntity():GetServerId(i) == packet.UserId) then
                    index = i;
                    break;
                end
            end
        end
        if (index == nil) then
            --User index was not found.
            return;
        end
        
        --Ability Ready
        if (packet.Type == 7) then
            local targets = T{};
            for _,target in ipairs(packet.Targets) do
                targets:append(target.Id);
            end
            local target = packet.Targets[1];
            if target then
                local action = target.Actions[1];
                if action then
                    if T{43, 675}:contains(action.Message) then
                        local abilityId = action.Param;
                        if (abilityId < 256) then
                            local ability = AshitaCore:GetResourceManager():GetAbilityById(abilityId);
                            if (ability) then
                                HandleAbility(index, ability.Name[1], targets);
                            else
                                HandleAbility(index, nil, targets);
                            end
                        else
                            local abilityName = AshitaCore:GetResourceManager():GetString('monsters.abilities', abilityId - 256);
                            HandleAbility(index, abilityName, targets);
                        end
                    elseif action.Message == 326 then
                        local abilityId = action.Param;
                        local ability = AshitaCore:GetResourceManager():GetAbilityById(abilityId);
                        if (ability) then
                            HandleAbility(index, ability.Name[1], targets);
                        else
                            HandleAbility(index, nil, targets);
                        end
                    end
                end
            end
        end
        
        --Spell Start
        if (packet.Type == 8) then
            local targets = T{};
            for _,target in ipairs(packet.Targets) do
                targets:append(target.Id);
            end
            local target = packet.Targets[1];
            if target then
                local action = target.Actions[1];
                if action then
                    local spellId = action.Param;
                    local spell = AshitaCore:GetResourceManager():GetSpellById(spellId);
                    HandleSpell(index, spell, targets);
                end
            end
        end
    end
end);

