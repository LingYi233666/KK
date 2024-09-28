
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {}

local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.K_K

local KK_REPAIRE_UP = 100

local SKINS_HUMANLIKE_LAST = SKINS_HUMANLIKE_LAST
local SKINS_NIGHTMARE_LAST = SKINS_NIGHTMARE_LAST
local CHARGED_LAST = TUNING.TOTAL_DAY_TIME
local SKINS_CAUTION_PERCENT = SKINS_CAUTION_PERCENT

local WX78MoistureMeter = require("widgets/wx78moisturemeter")
local easing = require("easing")
local MOISTURETRACK_TIMERNAME = "moisturetrackingupdate"

local function initiate_moisture_update(inst)
    if not inst.components.timer:TimerExists(MOISTURETRACK_TIMERNAME) then
        inst.components.timer:StartTimer(MOISTURETRACK_TIMERNAME, TUNING.WX78_MOISTUREUPDATERATE*FRAMES)
    end
end

local function stop_moisturetracking(inst)
    inst.components.timer:StopTimer(MOISTURETRACK_TIMERNAME)

    inst._moisture_steps = 0
end

local function moisturetrack_update(inst)
    local current_moisture = inst.components.moisture:GetMoisture()
    if current_moisture > TUNING.WX78_MINACCEPTABLEMOISTURE then
        -- The update will loop until it is stopped by going under the acceptable moisture level.
        initiate_moisture_update(inst)
    end

    if inst:HasTag("moistureimmunity") then
        return
    end

    inst._moisture_steps = inst._moisture_steps + 1

    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("sparks").Transform:SetPosition(x, y + 1 + math.random() * 1.5, z)

    if inst._moisture_steps >= TUNING.WX78_MOISTURESTEPTRIGGER then
        local damage_per_second = easing.inSine(
                current_moisture - TUNING.WX78_MINACCEPTABLEMOISTURE,
                TUNING.WX78_MIN_MOISTURE_DAMAGE,
                TUNING.WX78_PERCENT_MOISTURE_DAMAGE,
                inst.components.moisture:GetMaxMoisture() - TUNING.WX78_MINACCEPTABLEMOISTURE
        )
        local seconds_per_update = TUNING.WX78_MOISTUREUPDATERATE / 30

        inst.components.health:DoDelta(inst._moisture_steps * seconds_per_update * damage_per_second, false, "water")
        inst._moisture_steps = 0

        SpawnPrefab("wx78_big_spark"):AlignToTarget(inst)

        inst.sg:GoToState("hit")
    end

    -- Send a message for the UI.
    inst:PushEvent("do_robot_spark")
    if inst.player_classified ~= nil then
        inst.player_classified.uirobotsparksevent:push()
    end
end

local function OnWetnessChanged(inst, data)
    if not (inst.components.health ~= nil and inst.components.health:IsDead()) then
        if data.new > TUNING.WX78_MINACCEPTABLEMOISTURE and data.old <= TUNING.WX78_MINACCEPTABLEMOISTURE then
            initiate_moisture_update(inst)
        elseif data.new <= TUNING.WX78_MINACCEPTABLEMOISTURE and data.old > TUNING.WX78_MINACCEPTABLEMOISTURE then
            stop_moisturetracking(inst)
        end
    end
end

local function OnDeath(inst)
    stop_moisturetracking(inst)
    if inst._gears_eaten > 0 then
        local dropgears = math.random(math.floor(inst._gears_eaten / 3), math.ceil(inst._gears_eaten / 2))
        local x, y, z = inst.Transform:GetWorldPosition()
        for i = 1, dropgears do
            local gear = SpawnPrefab("gears")
            if gear ~= nil then
                if gear.Physics ~= nil then
                    local speed = 2 + math.random()
                    local angle = math.random() * 2 * PI
                    gear.Physics:Teleport(x, y + 1, z)
                    gear.Physics:SetVel(speed * math.cos(angle), speed * 3, speed * math.sin(angle))
                else
                    gear.Transform:SetPosition(x, y, z)
                end

                if gear.components.propagator ~= nil then
                    gear.components.propagator:Delay(5)
                end
            end
        end

        inst._gears_eaten = 0
    end
end

local function OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.components.edible.foodtype == FOODTYPE.GEARS then
            --[[if inst.components.health ~= nil then
                inst.components.health:DoDelta(food.components.edible:GetHealth(inst), true, food.prefab)
            end]]
            inst._gears_eaten = inst._gears_eaten + 1
        elseif food.components.edible.foodtype == FOODTYPE.NIGHTMAREFUEL then
            inst._nightmarefuel_eaten = inst._nightmarefuel_eaten + 1
            if inst._nightmarefuel_eaten >= 4 then
                inst.sg:GoToState("kk_change_nightmare_pre")
                inst._nightmarefuel_eaten = 0
            end
            inst:AddSkinLastingTime("KK_SKINS_NIGHTMARE", SKINS_NIGHTMARE_LAST, .25)
        end
    end
end

local function spawnchargedlight(inst)
    if not inst._kk_charged_light then
        inst._kk_charged_light = SpawnPrefab("kk_cane_light")
        inst._kk_charged_light.entity:SetParent(inst.entity)
    end
    inst._kk_charged_light.Light:Enable(true)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kk_charged", 1.15)
end

local function OnCharged(inst)
    inst.kk_charged = true
    spawnchargedlight(inst)
    if inst.components.hunger then
        inst.components.hunger:DoDelta(100, false, "lightning")
    end
    if inst.components.sanity then
        inst.components.sanity:DoDelta(-30)
    end

    if inst.components.timer:TimerExists("KK_CHARGED") then
        inst.components.timer:StopTimer("KK_CHARGED")
    end
    inst:DoTaskInTime(0, function() inst.components.timer:StartTimer("KK_CHARGED", CHARGED_LAST) end)

    local chargeable_items = inst.components.inventory:FindItems(function(item) return item:HasTag("kk_chargeable") end)
    for _,target in pairs(chargeable_items) do
        if target.components.finiteuses ~= nil then
            local percent = target.components.finiteuses:GetPercent()
            target.components.finiteuses:SetPercent(math.min(percent+0.05, 1))
        elseif target.components.fueled ~= nil then
            local percent = target.components.fueled:GetPercent()
            target.components.fueled:SetPercent(math.min(percent+0.05, 1))  
        end
    end
end

local function StopCharged(inst)
    inst.kk_charged = nil
    if inst._kk_charged_light then
        inst._kk_charged_light:Remove()
        inst._kk_charged_light = nil
    end
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kk_charged")
end

local function OnLightningStrike(inst)
    if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
        if inst.components.inventory:IsInsulated() then
            inst:PushEvent("lightningdamageavoided")
        else
            OnCharged(inst)
            local mult = TUNING.ELECTRIC_WET_DAMAGE_MULT * inst.components.moisture:GetMoisturePercent()
            local damage = TUNING.LIGHTNING_DAMAGE + mult * TUNING.LIGHTNING_DAMAGE
            inst.components.health:DoDelta(-damage*0.25, false, "lightning")
        end
    end
end

local function OnChargeFromBattery(inst, battery)
    if inst.kk_charged then
        return false, "CHARGE_FULL"
    end
    OnCharged(inst)

    return true
end

local function RemoveSkinsBuff(inst, skin)
    if inst.kk_state == "repaired" then
        inst.MiniMapEntity:SetIcon("k_k_repaired.tex")
    else
        inst.MiniMapEntity:SetIcon("k_k.tex")
    end
    inst.soundsname = "wx78"

    if inst:HasTag("kk_skins") then
        inst:RemoveTag("kk_skins")
    end

    if inst.components.timer:TimerExists("KK_SKINS_CAUTION") then
        inst.components.timer:StopTimer("KK_SKINS_CAUTION")
    end

    if (not skin or skin == "humanlike") then
        if inst.components.timer:TimerExists("KK_SKINS_HUMANLIKE") then
            inst.components.timer:StopTimer("KK_SKINS_HUMANLIKE")
        end
        if not inst:HasTag("pighatekk") then
            inst:AddTag("pighatekk")
        end
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "k_k_humanlike")
        inst.components.sanityaura.aura = 0
        --inst.components.sanity.dapperness = 0
        inst.components.sanity.externalmodifiers:RemoveModifier(inst, "k_k_humanlike")
    end

    if (not skin or skin == "nightmare") then
        if inst.components.timer:TimerExists("KK_SKINS_NIGHTMARE") then
            inst.components.timer:StopTimer("KK_SKINS_NIGHTMARE")
        end
        if inst.skins_nightmare_fx ~= nil then
            inst.skins_nightmare_fx:Remove()
            inst.skins_nightmare_fx = nil
        end
        if inst.kk_nightmare_trailtask ~= nil then
            inst.kk_nightmare_trailtask:Cancel()
            inst.kk_nightmare_trailtask = nil
        end
        if inst.components.grue ~= nil then
            inst.components.grue:RemoveImmunity("KK_SKINS_NIGHTMARE")
        end
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "KK_SKINS_NIGHTMARE")
        inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
        inst.components.sanity.get_equippable_dappernessfn = nil
    end
end

local TRAIL_FLAGS = { "shadowtrail" }
local function do_trail(inst)
    if not inst.entity:IsVisible() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.sg ~= nil and inst.sg:HasStateTag("moving") then
        local theta = -inst.Transform:GetRotation() * DEGREES
        local speed = inst.components.locomotor:GetRunSpeed() * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
    local mounted = inst.components.rider ~= nil and inst.components.rider:IsRiding()
    local map = TheWorld.Map
    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
        (mounted and 1 or .5) + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:IsPassableAtPoint(pt:Get())
                and not map:IsPointNearHole(pt)
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, TRAIL_FLAGS) <= 0
        end
    )

    if offset ~= nil then
        SpawnPrefab("cane_ancient_fx").Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end

local function RemoveSkins(inst, skin)
    RemoveSkinsBuff(inst, skin)
    inst.kk_skins = nil
    inst.components.skinner:SetSkinName("")
end

local function GetEquippableDapperness(owner, equippable)
    local dapperness = equippable:GetDapperness(owner, owner.components.sanity.no_moisture_penalty)
    if equippable.inst:HasTag("shadow_item") then
        return 0
    end

    return dapperness
end

local function OnStateChanged(inst, data)
    local onload = data and data.onload
    local repaire = data and data.repaire
    local skins = data and data.kk_skins
    local newskins = data and data.newskins

    if inst.kk_changestate then      
        inst:RemoveEventCallback("animqueueover", inst.kk_changestate)
        inst.kk_changestate = nil
    end

    if data ~= nil then 
        if data.fx then
            local fx = SpawnPrefab(type(data.fx)=="string" and data.fx or "collapse_small")
            if fx then
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end
    end

    if newskins and skins then
        RemoveSkinsBuff(inst)
        if skins == "humanlike" then
            inst:DoTaskInTime(0, function() 
                if not inst.components.timer:TimerExists("KK_SKINS_HUMANLIKE") then
                    inst.components.timer:StartTimer("KK_SKINS_HUMANLIKE", SKINS_HUMANLIKE_LAST)
                end
                if not inst.components.timer:TimerExists("KK_SKINS_CAUTION") then
                    inst.components.timer:StartTimer("KK_SKINS_CAUTION", SKINS_HUMANLIKE_LAST*(1-SKINS_CAUTION_PERCENT))
                end 
            end)
        elseif skins == "nightmare" then
            inst:DoTaskInTime(0, function() 
                if not inst.components.timer:TimerExists("KK_SKINS_NIGHTMARE") then
                    inst.components.timer:StartTimer("KK_SKINS_NIGHTMARE", SKINS_NIGHTMARE_LAST)
                end
                if not inst.components.timer:TimerExists("KK_SKINS_CAUTION") then
                    inst.components.timer:StartTimer("KK_SKINS_CAUTION", SKINS_NIGHTMARE_LAST*(1-SKINS_CAUTION_PERCENT))
                end 
            end)
        end
    end

    local _skin = skins or inst.kk_skins
    if _skin then
        --inst.components.skinner:SetSkinMode(_skin)
        inst.kk_skins = _skin
        inst.components.skinner:SetSkinName("k_k_".._skin)
        if not inst:HasTag("kk_skins") then
            inst:AddTag("kk_skins")
        end
    end

    if inst.kk_skins == "humanlike" then
        inst.MiniMapEntity:SetIcon("k_k_humanlike.tex")
        inst.soundsname = "willow"

        if inst:HasTag("pighatekk") then
            inst:RemoveTag("pighatekk")
        end
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "k_k_humanlike", 1.2)
        inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
        --inst.components.sanity.dapperness = TUNING.SANITYAURA_SMALL
        inst.components.sanity.externalmodifiers:SetModifier(inst, TUNING.SANITYAURA_SMALL, "k_k_humanlike")
    elseif inst.kk_skins == "nightmare" and (data and data.forcenightmare or inst.kk_state ~= "repaired") then
        inst.MiniMapEntity:SetIcon("k_k_nightmare.tex")
        local fxdelay = data and data.delay or .1
        inst:DoTaskInTime(fxdelay, function()
            if inst.skins_nightmare_fx == nil then
                local fx = SpawnPrefab("kk_shadow_fx")
                fx.Follower:FollowSymbol(inst.GUID, "headbase", 0, -30, 0, true)
                --fx.entity:SetParent(inst.entity)
                inst.skins_nightmare_fx = fx
                fx.parent = inst
            end
        end)
        if inst.kk_nightmare_trailtask == nil then
            inst.kk_nightmare_trailtask = inst:DoPeriodicTask(6 * FRAMES, do_trail, 2 * FRAMES)
        end
        if inst.components.grue ~= nil then
            inst.components.grue:AddImmunity("KK_SKINS_NIGHTMARE")
        end
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kk_charged", 1.25)
        inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD*0.675)
        inst.components.sanity.get_equippable_dappernessfn = GetEquippableDapperness
    elseif inst.kk_state == "repaired" then
        inst.MiniMapEntity:SetIcon("k_k_repaired.tex")
    elseif inst.kk_state == "normal" then
        inst.MiniMapEntity:SetIcon("k_k.tex")
    end

    if skins and data.norefreshstate then
        return
    end

    if inst.kk_state == "normal" then
        inst.components.skinner:SetSkinMode("normal_skin")

        inst.components.sanity.night_drain_mult = 1.1
        inst.components.sanity.neg_aura_mult = 1.1

        inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP

        inst.components.temperature.inherentinsulation = -30
        inst.components.temperature.inherentsummerinsulation = -30

        inst.components.hunger.hungerrate = 1.2 * TUNING.WILSON_HUNGER_RATE

        local current_health_percent = inst.components.health:GetPercent()
        inst.components.health.maxhealth = TUNING.K_K_HEALTH

        local current_sanity_percent = inst.components.sanity:GetPercent()
        inst.components.sanity:SetMax(TUNING.K_K_SANITY)

        local current_hunger_percent = inst.components.hunger:GetPercent()
        inst.components.hunger:SetMax(TUNING.K_K_HUNGER)

        if not onload then
            inst.components.health:SetPercent(current_health_percent)
            inst.components.health:DoDelta(0, false, nil, true)

            inst.components.sanity:SetPercent(current_sanity_percent, false)

            inst.components.hunger:SetPercent(current_hunger_percent, false)
        end

        if inst.kk_skins == "humanlike" then
            RemoveSkins(inst, inst.kk_skins)
        end

        if inst:HasTag("kk_repaired") then
            inst:RemoveTag("kk_repaired")
        end

        inst.components.playervision:SetCustomCCTable(KK_INSANITY_COLOURCUBES)
        inst:DoTaskInTime(.1, function() SendModRPCToClient(CLIENT_MOD_RPC[KK_MODNAME]["darkvision"], inst.userid, true) end)
    elseif inst.kk_state == "repaired" then
        inst.components.skinner:SetSkinMode("repaired_skin")

        inst.components.sanity.night_drain_mult = 1
        inst.components.sanity.neg_aura_mult = 1

        inst.components.temperature.mintemp = 10

        inst.components.temperature.inherentinsulation = 0
        inst.components.temperature.inherentsummerinsulation = 0

        inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

        local current_health_percent = inst.components.health:GetPercent()
        inst.components.health.maxhealth = TUNING.K_K_HEALTH + KK_REPAIRE_UP

        local current_sanity_percent = inst.components.sanity:GetPercent()
        inst.components.sanity:SetMax(TUNING.K_K_SANITY + KK_REPAIRE_UP)

        local current_hunger_percent = inst.components.hunger:GetPercent()
        inst.components.hunger:SetMax(TUNING.K_K_HUNGER + KK_REPAIRE_UP)

        if not onload then
            inst.components.health:SetPercent(current_health_percent)
            inst.components.health:DoDelta(0, false, nil, true)

            inst.components.sanity:SetPercent(current_sanity_percent, false)
            inst.components.hunger:SetPercent(current_hunger_percent, false)
        end

        if repaire then
            inst.components.health:DoDelta(TUNING.K_K_HEALTH + KK_REPAIRE_UP, false, "kk_repaire", true)
            inst.components.sanity:DoDelta(TUNING.K_K_SANITY + KK_REPAIRE_UP, false)
            inst.components.hunger:DoDelta(TUNING.K_K_HUNGER + KK_REPAIRE_UP, false, "kk_repaire")
        end

        if inst.kk_skins == "nightmare" then
            RemoveSkins(inst, inst.kk_skins)
        end

        if not inst:HasTag("kk_repaired") then
            inst:AddTag("kk_repaired")
        end
        if data and data.delay and data.delay > 0 then
            inst:DoTaskInTime(data.delay, function() 
                inst.components.playervision:SetCustomCCTable(nil)
                SendModRPCToClient(CLIENT_MOD_RPC[KK_MODNAME]["darkvision"], inst.userid, nil) 
            end)
        else
            inst.components.playervision:SetCustomCCTable(nil)
            inst:DoTaskInTime(.1, function() SendModRPCToClient(CLIENT_MOD_RPC[KK_MODNAME]["darkvision"], inst.userid, nil) end)
        end
        
    elseif inst.kk_state == "ghost" then
        inst.components.playervision:SetCustomCCTable(nil)
        inst:DoTaskInTime(.1, function() SendModRPCToClient(CLIENT_MOD_RPC[KK_MODNAME]["darkvision"], inst.userid, nil) end)
    end
end

local function OnAreaChanged(inst)
    if inst.components.areaaware:CurrentlyInTag("Nightmare") and inst.kk_skins ~= "nightmare" then
        inst.sg:GoToState("kk_change_nightmare_pre")
    end
end

local function OnTimerFinished(inst, data)
    if data.name == MOISTURETRACK_TIMERNAME then
        moisturetrack_update(inst)
    elseif data.name == "KK_CHARGED" then
        StopCharged(inst)
    elseif data.name ~= "KK_SKINS_CAUTION" and string.match(data.name, "KK_SKINS_.*") then
        RemoveSkins(inst)
        inst:PushEvent("kk_statechanged", {onload=false, norefreshstate=true, fx="shadow_puff_large_front"})
    elseif data.name == "KK_SKINS_CAUTION" then
        if inst.components.talker ~= nil then
            inst.components.talker:Say(STRINGS.KK_COATING_CAUTION)
        end
    end
end

local function ondaycomplete(inst)
    inst._nightmarefuel_eaten = 0
end

local function OnLSD(inst, data)
    if math.random() < 0.1 then
        local product = SpawnPrefab("gears")
        product.Transform:SetPosition(inst:GetPosition():Get())
        if product.Physics then
            local angle = math.random()*2*PI
            product.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))
        end
        if inst.components.talker then
            inst.components.talker:Say(KK_SETSTRING("过分了!", "That's too much!"))
        end
    else
        if inst.components.talker then
            inst.components.talker:Say(KK_SETSTRING("轻点啦!", "Please be gentle!"))
        end
    end
end

local function onbecamehuman(inst, data)
    local onload = data and data.onload
    if not onload then
        inst.kk_state = "normal"
        if not inst.kk_changestate then
            inst.kk_changestate = function() OnStateChanged(inst, {onload=false}) end
        end
        inst:ListenForEvent("animqueueover", inst.kk_changestate)
    else
        OnStateChanged(inst, {onload=true})
    end
end

local function onbecameghost(inst, data)
    if inst.components.timer:TimerExists("KK_CHARGED") then
        inst.components.timer:StopTimer("KK_CHARGED")
    end
    StopCharged(inst)

    RemoveSkins(inst)
    inst.kk_state = "ghost"
    local onload = data and data.onload
    if not onload then
        if inst:HasTag("kk_repaired") then
            local wreckage = SpawnPrefab("kk_wreckage")
            wreckage.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:RemoveTag("kk_repaired")
        end
        inst.components.playervision:SetCustomCCTable(nil)
        inst:DoTaskInTime(.1, function() SendModRPCToClient(CLIENT_MOD_RPC[KK_MODNAME]["darkvision"], inst.userid, nil) end)
    else
        OnStateChanged(inst, {onload=true})
    end
end

local function onsave(inst, data)
    data._gears_eaten = inst._gears_eaten
    data._nightmarefuel_eaten = inst._nightmarefuel_eaten

    data.kk_state = inst.kk_state
    data.kk_charged = inst.kk_charged
    data.kk_skins = inst.kk_skins

    data._kk_health = inst.components.health.currenthealth
    data._kk_sanity = inst.components.sanity.current
    data._kk_hunger = inst.components.hunger.current
end

local function onload(inst, data)
    if data and data._gears_eaten ~= nil then
        inst._gears_eaten = data._gears_eaten
    end
    if data and data._nightmarefuel_eaten ~= nil then
        inst._nightmarefuel_eaten = data._nightmarefuel_eaten
    end

    inst.kk_state = data and data.kk_state or "normal"
    inst.kk_charged = data and data.kk_charged
    if inst.kk_charged then
        spawnchargedlight(inst)
    end

    inst.kk_skins = data and data.kk_skins

    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst, {onload=true})
    else
        onbecamehuman(inst, {onload=true})
    end

    if data ~= nil then    
        if data._kk_health then
            inst.components.health:SetCurrentHealth(data._kk_health)
        end

        if data._kk_sanity then
            inst.components.sanity.current = data._kk_sanity
        end

        if data._kk_hunger then
            inst.components.hunger.current = data._kk_hunger
        end
    end
end

local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "k_k.tex" )

    inst:AddTag("k_k")
    inst:AddTag("pighatekk")
    inst:AddTag("batteryuser")
    inst:AddTag("soulless")
    inst:AddTag("magician")

    --inst:AddTag("chessfriend")
    if TheNet:GetServerGameMode() ~= "quagmire" and not TheNet:IsDedicated() then
        inst.CreateMoistureMeter = WX78MoistureMeter
    end

    if inst.components.playervision ~= nil then
        local old_SetCustomCCTable = inst.components.playervision.SetCustomCCTable
        inst.components.playervision.SetCustomCCTable = function(self, cctable, ...)
            if not inst:HasTag("kk_repaired") and cctable ~= KK_INSANITY_COLOURCUBES then
                return
            end
            return old_SetCustomCCTable(self, cctable, ...)
        end
    end

    local Hide_old = inst.Hide
    inst.Hide = function(self, ...)
        if inst.skins_nightmare_fx ~= nil and inst.skins_nightmare_fx:IsValid() then
            inst.skins_nightmare_fx:Hide()
        end
        return Hide_old(self, ...)
    end

    local Show_old = inst.Show
    inst.Show = function(self, ...)
        if inst.skins_nightmare_fx ~= nil and inst.skins_nightmare_fx:IsValid() then
            inst.skins_nightmare_fx:Show()
        end
        return Show_old(self, ...)
    end

    inst._humanlike_last = net_ushortint(inst.GUID, "k_k._humanlike_last")
    inst._nightmare_last = net_ushortint(inst.GUID, "k_k._nightmare_last")
end

local master_postinit = function(inst)
	inst.soundsname = "wx78"

	inst.components.foodaffinity:AddPrefabAffinity("waffles", TUNING.AFFINITY_15_CALORIES_LARGE)
	inst.components.health:SetMaxHealth(TUNING.K_K_HEALTH)
	inst.components.hunger:SetMax(TUNING.K_K_HUNGER)
	inst.components.sanity:SetMax(TUNING.K_K_SANITY)

    inst.components.combat.damagemultiplier = 1

    inst.components.builder.science_bonus = 2
    ----------------------------------------------------------------
    inst._gears_eaten = 0
    inst._moisture_steps = 0
    inst._nightmarefuel_eaten = 0

    inst.kk_state = "normal"
    inst.skeleton_prefab = "kk_wreckage_point"

    inst.AddSkinLastingTime = function(inst, name, max, pct)
        if inst.components.timer:TimerExists(name) then
            local time_left = inst.components.timer:GetTimeLeft(name)
            if time_left < max then
                inst.components.timer:StopTimer(name)
                local new_time = math.min(time_left + max * pct, max)
                inst.components.timer:StartTimer(name, new_time)
                local caution_time = max*(1-SKINS_CAUTION_PERCENT)
                if new_time >= caution_time then
                    inst.components.timer:StopTimer("KK_SKINS_CAUTION")
                    inst.components.timer:StartTimer("KK_SKINS_CAUTION", caution_time)
                end
            end
        end
    end

    inst:DoPeriodicTask(6 * FRAMES, function() 
        if inst.components.timer:TimerExists("KK_SKINS_HUMANLIKE") then
            if inst._humanlike_last then
                inst._humanlike_last:set(inst.components.timer:GetTimeLeft("KK_SKINS_HUMANLIKE"))
            end
        else
            if inst._humanlike_last and inst._humanlike_last:value() ~= 0 then
                inst._humanlike_last:set(0)
            end
        end
        if inst.components.timer:TimerExists("KK_SKINS_NIGHTMARE") then
            if inst._nightmare_last then
                inst._nightmare_last:set(inst.components.timer:GetTimeLeft("KK_SKINS_NIGHTMARE"))
            end
        else
            if inst._nightmare_last and inst._nightmare_last:value() ~= 0 then
                inst._nightmare_last:set(0)
            end
        end
    end, 2 * FRAMES)

    if inst.components.temperature ~= nil then
        local old_SetTemperature = inst.components.temperature.SetTemperature
        inst.components.temperature.SetTemperature = function(self, value, ...)
            local delta = value-self.current
            if delta > 0 then
                value = self.current + delta * 1.5
            end
            return old_SetTemperature(self,value, ...)
        end
    end

    if inst.components.eater ~= nil then
        inst.components.eater:SetIgnoresSpoilage(true)
        inst.components.eater:SetCanEatGears()
        inst.components.eater:SetOnEatFn(OnEat)
        inst.components.eater.custom_stats_mod_fn = function(inst, health_delta, hunger_delta, sanity_delta, food)
            if inst.kk_skins == "humanlike" then
                hunger_delta = food.kk_eat_hunger or hunger_delta
                health_delta = food.kk_eat_health or health_delta
                sanity_delta = food.kk_eat_sanity or sanity_delta

                return health_delta, hunger_delta, sanity_delta
            end
            hunger_delta = food.kk_eat_hunger or (hunger_delta > 0 and hunger_delta/2 or 0)
            if food.components.edible.foodtype ~= FOODTYPE.GEARS then
                health_delta = 0
            end
            health_delta = food.kk_eat_health or health_delta
            sanity_delta = food.kk_eat_sanity or 0

            return health_delta, hunger_delta, sanity_delta
        end
        local old_TestFood = inst.components.eater.TestFood
        inst.components.eater.TestFood = function(self, food, ...)
            if food:HasTag("kk_caneat") then
                return true
            end
            return old_TestFood(self, food, ...)
        end

        table.insert(inst.components.eater.preferseating, FOODTYPE.NIGHTMAREFUEL)
        table.insert(inst.components.eater.caneat, FOODTYPE.NIGHTMAREFUEL)
        inst:AddTag(FOODTYPE.NIGHTMAREFUEL.."_eater")
    end

    if inst.components.combat ~= nil then
        local old_GetAttacked = inst.components.combat.GetAttacked
        inst.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli, ...)
            if stimuli and stimuli == "electric" then
                damage = damage * 0.25
                OnCharged(inst)
            end
            if inst.kk_state == "normal" then
                damage = damage + 15
            end
            return old_GetAttacked(self, attacker, damage, weapon, stimuli, ...)
        end

        local GetBattleCryString_old = inst.components.combat.GetBattleCryString
        inst.components.combat.GetBattleCryString = function(combat, target)
            local string = GetBattleCryString_old ~= nil and GetBattleCryString_old(combat, target)
            return (
                target ~= nil
                and target:IsValid()
                and GetString(
                    combat.inst,
                    "BATTLECRY",
                    (target:HasTag("chess") and "CHESS") or
                    (target:HasTag("spider") and "SPIDERS") or
                    target.prefab
                )
                or nil
            ) or string
        end
    end

    local SetSkinName_old = inst.components.skinner.SetSkinName
    inst.components.skinner.SetSkinName = function(self, skin_name, ...)
        if skin_name and skin_name ~= "" then
            local _skin, find = skin_name:gsub("k_k_(.*)", "%1")
            if find and find > 0 then
                if inst.kk_skins ~= _skin or (_skin == "none" and inst.kk_skins ~= nil) then
                    skin_name = "k_k_"..(inst.kk_skins or "none")
                    --return
                end
            end
        end
        return SetSkinName_old(self, skin_name, ...)
    end

    if inst.components.cursable ~= nil then
        local ApplyCurse_old = inst.components.cursable.ApplyCurse
        inst.components.cursable.ApplyCurse = function(self, item, curse, ...)
            if item and item:HasTag("monkey_token") then
                return false
            end
            return ApplyCurse_old(self, item, curse, ...)
        end
        local IsCursable_old = inst.components.cursable.IsCursable
        inst.components.cursable.IsCursable = function(self, item, ...)
            if item and item:HasTag("monkey_token") then
                return false
            end
            return IsCursable_old(self, item, ...)
        end
    end

    --if inst.components.sleepingbaguser ~= nil then
    --    inst.components.sleepingbaguser:SetCanSleepFn(function() return false, "ANNOUNCE_NODAYSLEEP_CAVE" end)
    --end

    inst.components.playerlightningtarget:SetHitChance(TUNING.WX78_LIGHTNING_TARGET_CHANCE)
    inst.components.playerlightningtarget:SetOnStrikeFn(OnLightningStrike)

    inst:AddComponent("magician")
    local old_StartUsingTool = inst.components.magician.StartUsingTool
    inst.components.magician.StartUsingTool = function(self, item, ...)
        if not item:HasTag("kk_wctophat") then
            return false
        end
        local r = old_StartUsingTool(self, item, ...)
        if self.item then
            self.item.entity:SetInLimbo(false)
            self.item:Hide()
        end
        return r
    end

    local old_OnLoad = inst.components.magician.OnLoad
    inst.components.magician.OnLoad = function(self, data, ...)
        old_OnLoad(self, data, ...)
        self:StopUsing()
    end

    inst:AddComponent("batteryuser")
    inst.components.batteryuser.onbatteryused = OnChargeFromBattery

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = 0
    inst.components.sanityaura.max_distsq = 8*8
    inst.components.sanityaura.fallofffn = function() return 1 end

    inst:AddComponent("kk_light")

    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("moisturedelta", OnWetnessChanged)
    inst:ListenForEvent("timerdone", OnTimerFinished)
    inst:ListenForEvent("kk_statechanged", OnStateChanged)
    inst:ListenForEvent("changearea", OnAreaChanged)

    inst:WatchWorldState("cycles", ondaycomplete)

    inst:ListenForEvent("xxxwumalsdspell", OnLSD)
	----------------------------------------------------------------
	inst.OnSave = onsave
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("k_k", prefabs, assets, common_postinit, master_postinit, start_inv)
