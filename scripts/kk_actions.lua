----------------------------------------------------------------
local function kk_action(sg)
    local old_caseaoe = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate =
        function(inst, action)
            if action.invobject then
                if action.invobject:HasTag("kk_dlc") then
                    return "mine_start"
                end
            end
            return old_caseaoe(inst, action)
        end

    local old_eat = sg.actionhandlers[ACTIONS.EAT].deststate
    sg.actionhandlers[ACTIONS.EAT] = ActionHandler(ACTIONS.EAT, function(inst, action)
        local obj = action.target or action.invobject
        if obj and obj.components.edible ~= nil and obj.components.edible.foodtype == FOODTYPE.NIGHTMAREFUEL then
            return "eat"
        end
        return old_eat(inst, action)
    end)
end

AddStategraphPostInit("wilson", function(sg) kk_action(sg) end)
AddStategraphPostInit("wilson_client", function(sg) kk_action(sg) end)



AddStategraphPostInit("wilson", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate

    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
        local old_result = old_ATTACK(inst, action, ...)
        local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil

        if old_result == "attack" then
            if weapon then
                if weapon.prefab == "kk_chainsword" then
                    return "kk_attack_chainsword"
                end
            end
        end

        return old_result
    end
end)

AddStategraphPostInit("wilson_client", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate

    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
        local old_result = old_ATTACK(inst, action, ...)
        local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if old_result == "attack" then
            if equip then
                if equip.prefab == "kk_chainsword" then
                    return "kk_attack_chainsword"
                end
            end
        end

        return old_result
    end
end)

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

local function SetSleeperSleepState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:AddImmunity("dormancy")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:IgnoreAll("dormancy")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Disable()
    end
    if inst.components.hunger ~= nil then
        inst.components.hunger.burnrate = 0.3
    end
    if inst.components.sanity ~= nil then
        inst.components.sanity.externalmodifiers:SetModifier(inst, TUNING.DAPPERNESS_LARGE, "kk_dormancy")
    end
end

local function SetSleeperAwakeState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:RemoveImmunity("dormancy")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("dormancy")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.hunger ~= nil then
        inst.components.hunger.burnrate = 1
    end
    if inst.components.sanity ~= nil then
        inst.components.sanity.externalmodifiers:RemoveModifier(inst, "kk_dormancy")
    end
end

local kk_dormancy_stop = State {
    name = "kk_dormancy_stop",
    tags = { "waking", "nomorph", "nodangle" },

    onenter = function(inst)
        inst.AnimState:PlayAnimation("emote_pst_sit2")
    end,

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        if IsServer then
            SetSleeperAwakeState(inst)
        end
    end,
}

AddStategraphState("wilson", kk_dormancy_stop)
AddStategraphState("wilson_client", kk_dormancy_stop)

local kk_dormancy = State {
    name = "kk_dormancy",
    tags = { "knockout", "nopredict", "nomorph", "kk_dormancy", "notalking" },
    onenter = function(inst)
        ForceStopHeavyLifting(inst)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()

        inst.AnimState:PlayAnimation("emote_pre_sit2")
        inst.AnimState:PushAnimation("emote_loop_sit2")

        if IsServer then
            SetSleeperSleepState(inst)
        end
    end,

    onexit = function(inst)
        if IsServer then
            SetSleeperAwakeState(inst)
        end
    end,

    timeline =
    {
        TimeEvent(24 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("nopredict")
            inst.sg:AddStateTag("idle")
        end),
    },

    events =
    {
        EventHandler("firedamage", function(inst)
            if inst.sg.statemem.sleeping and not inst.sg:HasStateTag("drowning") then
                inst.sg:GoToState("kk_dormancy_stop")
            else
                inst.sg.statemem.cometo = true
            end
        end),

        EventHandler("kk_stopdormancy", function(inst)
            if inst.sg.statemem.sleeping and not inst.sg:HasStateTag("drowning") then
                inst.sg:GoToState("kk_dormancy_stop")
            else
                inst.sg.statemem.cometo = true
            end
        end),

        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                if inst.sg.statemem.cometo then
                    inst.sg:GoToState("kk_dormancy_stop")
                else
                    inst.AnimState:PlayAnimation("emote_loop_sit2", true)
                    inst.sg.statemem.sleeping = true
                end
            end
        end),
    },
}

AddStategraphState("wilson", kk_dormancy)

local kk_coating = State {
    name = "kk_coating",
    tags = { "inwardrobe", "busy", "nopredict", "silentmorph", "temp_invincible" },

    onenter = function(inst, delay)
        ForceStopHeavyLifting(inst)
        inst:Hide()
        inst.DynamicShadow:Enable(false)
        inst.sg.statemem.isplayerhidden = true

        inst.components.locomotor:Stop()
        inst.components.locomotor:Clear()
        inst:ClearBufferedAction()

        inst.AnimState:PlayAnimation("idle_wardrobe1_pre")
        inst.AnimState:PushAnimation("idle_wardrobe1_loop", true)

        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:RemotePausePrediction()
            inst.components.playercontroller:EnableMapControls(false)
            inst.components.playercontroller:Enable(false)
        end
        inst.components.inventory:Hide()
        inst:PushEvent("ms_closepopups")
        inst:ShowActions(false)

        inst.sg:SetTimeout(delay or 31 * FRAMES)
    end,

    ontimeout = function(inst)
        inst.AnimState:PlayAnimation("jumpout_wardrobe")
        inst:Show()
        inst.DynamicShadow:Enable(true)
        inst.sg.statemem.isplayerhidden = nil
        inst.sg.statemem.task = inst:DoTaskInTime(4.5 * FRAMES, function()
            inst.sg.statemem.task = nil
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end)
    end,

    events =
    {
        EventHandler("animover", function(inst)
            if not inst.sg.statemem.isplayerhidden and inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        if inst.sg.statemem.task ~= nil then
            inst.sg.statemem.task:Cancel()
            inst.sg.statemem.task = nil
        end
        if inst.sg.statemem.isplayerhidden then
            inst:Show()
            inst.DynamicShadow:Enable(true)
            inst.sg.statemem.isplayerhidden = nil
        end
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:EnableMapControls(true)
            inst.components.playercontroller:Enable(true)
        end
        inst.components.inventory:Show()
        inst:ShowActions(true)
    end,
}

AddStategraphState("wilson", kk_coating)

local kk_cabin = State {
    name = "kk_cabin",
    tags = { "kk_cabin", "nopredict", "silentmorph", "noattack" },

    onenter = function(inst)
        ForceStopHeavyLifting(inst)
        inst:Hide()
        inst.DynamicShadow:Enable(false)
        inst.sg.statemem.isplayerhidden = true

        inst.components.locomotor:Stop()
        inst.components.locomotor:Clear()
        inst:ClearBufferedAction()

        --inst.AnimState:PlayAnimation("idle_wardrobe1_pre")
        --inst.AnimState:PushAnimation("idle_wardrobe1_loop", true)

        inst.components.inventory:Hide()
        inst:PushEvent("ms_closepopups")
        inst:ShowActions(false)

        if inst.Physics then
            inst.Physics:SetCollides(false)
        end

        if inst.kk_cabin_task ~= nil then
            inst.kk_cabin_task:Cancel()
            inst.kk_cabin_task = nil
        end

        inst.kk_cabin_task = inst:DoPeriodicTask(1, function()
            if inst.components.health ~= nil then
                if inst.components.health:GetPenaltyPercent() > 0 then
                    inst.components.health:DeltaPenalty(-.02)
                end
                inst.components.health:DoDelta(3, true)
            end
            if inst.components.sanity ~= nil then
                inst.components.sanity:DoDelta(10 / 3, true)
            end
            if inst.components.hunger ~= nil then
                inst.components.hunger:DoDelta(10 / 3, true)
            end
            if inst.kk_skins == "humanlike" then
                inst:AddSkinLastingTime("KK_SKINS_HUMANLIKE", SKINS_HUMANLIKE_LAST, 1 / 60)
            end
        end)

        if IsServer then
            if inst.components.grue ~= nil then
                inst.components.grue:AddImmunity("dormancy")
            end
            if inst.components.talker ~= nil then
                inst.components.talker:IgnoreAll("dormancy")
            end
            if inst.components.firebug ~= nil then
                inst.components.firebug:Disable()
            end
        end
    end,

    timeline =
    {
        TimeEvent(24 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("nopredict")
            inst.sg:AddStateTag("idle")
        end),
    },

    events =
    {
        --[[EventHandler("animover", function(inst)
                if not inst.sg.statemem.isplayerhidden and inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),]]
    },

    onexit = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:RemotePausePrediction()
            inst.components.playercontroller:EnableMapControls(false)
            inst.components.playercontroller:Enable(false)
        end

        if inst.Physics then
            local pt = inst:GetPosition()
            inst.Physics:Teleport(pt.x, 0, pt.z)
            inst.Physics:SetCollides(true)
        end

        if inst.kk_cabin ~= nil and inst.kk_cabin.components.kk_dormancy ~= nil then
            inst.kk_cabin.components.kk_dormancy:Stop(inst)
        end

        if inst.kk_cabin_task ~= nil then
            inst.kk_cabin_task:Cancel()
            inst.kk_cabin_task = nil
        end

        inst.components.inventory:Show()
        inst:ShowActions(true)
        inst.AnimState:PlayAnimation("jumpout_wardrobe")
        inst:DoTaskInTime(.8, function()
            inst:Show()
            inst.DynamicShadow:Enable(true)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
        end)

        if IsServer then
            if inst.components.grue ~= nil then
                inst.components.grue:RemoveImmunity("dormancy")
            end
            if inst.components.talker ~= nil then
                inst.components.talker:StopIgnoringAll("dormancy")
            end
            if inst.components.firebug ~= nil then
                inst.components.firebug:Enable()
            end
        end
    end,
}

AddStategraphState("wilson", kk_cabin)

local kk_change_nightmare_pre = State {
    name = "kk_change_nightmare_pre",
    tags = { "busy", "nopredict", "temp_invincible", "nomorph", "nodangle" },

    onenter = function(inst)
        ForceStopHeavyLifting(inst)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()

        if inst.components.rider:IsRiding() then
            inst.sg:AddStateTag("dismounting")
            inst.AnimState:PlayAnimation("fall_off")
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
        else
            SpawnAt("kk_nightmare_transform_fx", inst)
            inst.AnimState:PlayAnimation("mindcontrol_pre")
        end
    end,

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                if inst.sg:HasStateTag("dismounting") then
                    inst.sg:RemoveStateTag("dismounting")
                    inst.components.rider:ActualDismount()
                    inst.AnimState:PlayAnimation("mindcontrol_pre")
                else
                    inst.sg:GoToState("kk_change_nightmare")
                end
            end
        end),
    },

    onexit = function(inst)
        if inst.sg:HasStateTag("dismounting") then
            inst.components.rider:ActualDismount()
        end
    end,
}

AddStategraphState("wilson", kk_change_nightmare_pre)

local kk_change_nightmare = State {
    name = "kk_change_nightmare",
    tags = { "busy", "nopredict", "temp_invincible", "nomorph", "nodangle" },

    onenter = function(inst)
        inst.AnimState:PlayAnimation("mindcontrol_loop")
        inst.sg:SetTimeout(6 * FRAMES)
    end,

    ontimeout = function(inst)
        inst.AnimState:PlayAnimation("mindcontrol_pst")
        inst.sg:GoToState("idle", true)
        inst:PushEvent("kk_statechanged", {
            onload = false,
            norefreshstate = true,
            newskins = true,
            kk_skins = "nightmare",
            forcenightmare = true,
            fx = "statue_transition_2",
            delay = 0,
            lightoff = true
        })
        if inst.components.kk_light ~= nil then
            inst.components.kk_light:UpdateAnim()
        end
    end,
}

AddStategraphState("wilson", kk_change_nightmare)

-- TODO: finish kk_chainsword attack SG
-- local kk_attack_chainsword_server =
-- AddStategraphState("wilson",kk_attack_chainsword_server)

--[[AddAction("KK_LIGHT", "Light", function(act)
    if act.doer and act.doer.components.kk_light then
        local target = act.target or act.doer
        return act.doer.components.kk_light:SwitchLight()
    end
    return false
end)

ACTIONS.KK_LIGHT.priority = 1
ACTIONS.KK_LIGHT.instant = true
ACTIONS.KK_LIGHT.mount_valid = true

STRINGS.ACTIONS.KK_LIGHT =
{
    GENERIC = "开灯",
    OFF = "关灯",
}

ACTIONS.KK_LIGHT.strfn = function(act)
    return act.target ~= nil
        and act.target:HasTag("kk_light_on")
        and "OFF"
        or nil
end

local function canlight(inst, doer, actions, right)
    if inst == doer and inst:HasTag("k_k") and inst:HasTag("kk_repaired") then
        table.insert(actions, ACTIONS.KK_LIGHT)
    end
end
AddComponentAction("SCENE", "kk_light", canlight)]]


AddAction("KK_CHARGE", KK_SETSTRING("充能", "충전", "Charge"), function(act)
    local target = act.target
    local doer = act.doer
    if act.invobject and act.invobject.components.kk_charger and act.invobject.components.kk_charger:CanCharge(doer, target) then
        return act.invobject.components.kk_charger:Charge(doer, target)
    end
    return false
end)

ACTIONS.KK_CHARGE.priority = 1

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.KK_CHARGE, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.KK_CHARGE, "doshortaction"))

local function cancharge(inst, doer, target, actions)
    if inst:HasTag("kk_charger") and target:HasTag("kk_chargeable") then
        table.insert(actions, ACTIONS.KK_CHARGE)
    end
end
AddComponentAction("USEITEM", "kk_charger", cancharge)

AddPrefabPostInit("nightstick", function(inst) inst:AddTag("kk_chargeable") end)

AddAction("KK_DORMANCY", KK_SETSTRING("进入", "들어오다", "Enter"), function(act)
    local target = act.target
    local doer = act.doer
    if doer and target and target.components.kk_dormancy then
        return target.components.kk_dormancy:Start(doer)
    end
    return false
end)

ACTIONS.KK_DORMANCY.priority = 1

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.KK_DORMANCY, "dostandingaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.KK_DORMANCY, "dostandingaction"))

local function candormancy(inst, doer, actions, right)
    if inst:HasTag("kk_dormancycabin") and inst:HasTag("candormancy") and inst:HasTag("powered") then
        table.insert(actions, ACTIONS.KK_DORMANCY)
    end
end
AddComponentAction("SCENE", "kk_dormancy", candormancy)
