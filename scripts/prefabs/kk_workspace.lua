require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/kk_workspace.zip"),
    Asset("ANIM", "anim/kk_powerdisplay.zip"),
    Asset("ANIM", "anim/gems.zip"),
}


local NUM_LEVELS = 6
local GEMSLOTS = 3
local LEVELS_PER_GEM = 2

local function GetGemSymbol(slot)
    return "gem"..tostring(GEMSLOTS - slot + 1)
end

local function SetGem(inst, slot, gemname)
    inst.AnimState:OverrideSymbol(GetGemSymbol(slot), "gems", "swap_"..gemname)
end

local function UnsetGem(inst, slot, gemname)
    local symbol = GetGemSymbol(slot)
    inst.AnimState:ClearOverrideSymbol(symbol)
    if not POPULATING then
        local fx = SpawnPrefab("winona_battery_high_shatterfx")
        fx.entity:AddFollower():FollowSymbol(inst.GUID, symbol, 0, 0, 0)
        local anim = gemname.."_shatter"
        if not fx.AnimState:IsCurrentAnimation(anim) then
            fx.AnimState:PlayAnimation(anim)
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    end
end
--------------------------------------------------------------------------
local PERIOD = .5

local function DoAddBatteryPower(inst, node)
    node:AddBatteryPower(PERIOD + math.random(2, 6) * FRAMES)
end

local function OnBatteryTask(inst)
    inst.components.circuitnode:ForEachNode(DoAddBatteryPower)
end

local function StartBattery(inst)
    if inst._batterytask == nil then
        inst._batterytask = inst:DoPeriodicTask(PERIOD, OnBatteryTask, 0)
    end
end

local function StopBattery(inst)
    if inst._batterytask ~= nil then
        inst._batterytask:Cancel()
        inst._batterytask = nil
    end
end

local function UpdateCircuitPower(inst)
    inst._circuittask = nil
    if inst.components.fueled ~= nil then
        if inst.components.fueled.consuming then
            local load = 0
            inst.components.circuitnode:ForEachNode(function(inst, node)
                local batteries = 0
                node.components.circuitnode:ForEachNode(function(node, battery)
                    if battery.components.fueled ~= nil and battery.components.fueled.consuming then
                        batteries = batteries + 1
                    end
                end)
                load = load + 1 / batteries
            end)
            inst.components.fueled.rate = math.max(load, TUNING.WINONA_BATTERY_MIN_LOAD)
        else
            inst.components.fueled.rate = 0
        end
    end
end

local function OnCircuitChanged(inst)
    if inst._circuittask == nil then
        inst._circuittask = inst:DoTaskInTime(0, UpdateCircuitPower)
    end
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function BroadcastCircuitChanged(inst)
    --Notify other connected nodes, so that they can notify their connected batteries
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
    if inst._circuittask ~= nil then
        inst._circuittask:Cancel()
    end
    UpdateCircuitPower(inst)
end

local function OnConnectCircuit(inst)--, node)
    if inst.components.fueled ~= nil and inst.components.fueled.consuming then
        StartBattery(inst)
    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if not inst.components.circuitnode:IsConnected() then
        StopBattery(inst)
    end
    OnCircuitChanged(inst)
end
--------------------------------------------------------------------------
local BATTERY_COST = TUNING.WINONA_BATTERY_LOW_MAX_FUEL_TIME * 0.9
local function CanBeUsedAsBattery(inst, user)
    if inst.components.fueled ~= nil and inst.components.fueled.currentfuel >= BATTERY_COST then
        return true
    else
        return false, "NOT_ENOUGH_CHARGE"
    end
end

local function UseAsBattery(inst, user)
    inst.components.fueled:DoDelta(-BATTERY_COST, user)
end
--------------------------------------------------------------------------
local function FlingGem(inst, gemname, slot)
    local pt = inst:GetPosition()
    pt.y = 2.5 + .5 * slot
    inst.components.lootdropper:SpawnLootPrefab(gemname, pt)
    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    end
end

local function LoseGem(inst, gemname, slot)
    local fx = SpawnPrefab("winona_battery_high_shatterfx")
    local anim = gemname.."_shatter"
    if not fx.AnimState:IsCurrentAnimation(anim) then
        fx.AnimState:PlayAnimation(anim)
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x, 2.5 + .75 * slot, z)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
end

local function DropGems(inst)
    if #inst._gems > 0 then
        for i, v in ipairs(inst._gems) do
            if i < #inst._gems then
                FlingGem(inst, v, i)
            else
                LoseGem(inst, v, i)
            end
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    DropGems(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
    if inst.components.fueled ~= nil then
        inst:RemoveComponent("fueled")
    end
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    local numgems = #inst._gems
    if numgems > 0 then
        for i = 1, numgems - 1 do
            FlingGem(inst, table.remove(inst._gems, 1), i)
        end
        LoseGem(inst, table.remove(inst._gems), numgems)
    end
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("changeskin") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function onturnon(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("changeskin") then
        if inst.AnimState:IsCurrentAnimation("active") or inst.AnimState:IsCurrentAnimation("onbuild") then
            inst.AnimState:PushAnimation("active", true)
        else
            inst.AnimState:PlayAnimation("active", true)
        end
    end
end

local function onturnoff(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("changeskin") then
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function doneact(inst)
    inst._activetask = nil
    if not inst:HasTag("burnt") then
        if inst.components.prototyper.on then
            onturnon(inst)
        else
            onturnoff(inst)
        end
    end
end

local function onactivate(inst)
    if not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("changeskin") then
        inst.AnimState:PlayAnimation("idle", false)
        if inst._activetask ~= nil then
            inst._activetask:Cancel()
        end
        inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
    end
end
--------------------------------------------------------------------------
local function GetStatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        return "BURNING"
    end
    local level = inst.components.fueled ~= nil and inst.components.fueled:GetCurrentSection() or nil
    return level ~= nil
        and (   (level <= 0 and "OFF") or
                (level <= 1 and "LOWPOWER")
            )
        or nil
end

local function ShatterGems(inst, keepnumgems)
    local i = #inst._gems
    if i > keepnumgems then
        if i == GEMSLOTS then
            inst.components.trader:Enable()
        end
        while i > keepnumgems do
            UnsetGem(inst, i, table.remove(inst._gems))
            i = i - 1
        end
    end
end

local function OnFuelEmpty(inst)
    inst.components.fueled:StopConsuming()
    BroadcastCircuitChanged(inst)
    StopBattery(inst)
    inst.AnimState:OverrideSymbol("powerdisplay", "kk_powerdisplay", "p1")
    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
    end
    ShatterGems(inst, 0)
end

local function OnFuelSectionChange(new, old, inst)
    inst.AnimState:OverrideSymbol("powerdisplay", "kk_powerdisplay", "p"..tostring(math.clamp(new + 1, 1, 7)))
    if new > 0 then
        ShatterGems(inst, math.ceil(new / LEVELS_PER_GEM))
    end
end

local function OnBuilt2(inst)
    inst:RemoveEventCallback("animover", OnBuilt2)
    inst.components.circuitnode:ConnectTo("engineering")
    inst.components.trader:Enable()
end

local function onbuilt(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.AnimState:PlayAnimation("onbuild")
    --inst.AnimState:PushAnimation("idle", true)
    inst.components.trader:Disable()
    inst:ListenForEvent("animover", OnBuilt2)
end
--------------------------------------------------------------------------
local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    elseif helperinst:IsNear(helperinst.placerinst, TUNING.WINONA_BATTERY_RANGE) then
        local hp = helperinst:GetPosition()
        local p1 = TheWorld.Map:GetPlatformAtPoint(hp.x, hp.z)

        local pp = helperinst.placerinst:GetPosition()
        local p2 = TheWorld.Map:GetPlatformAtPoint(pp.x, pp.z)

        if p1 == p2 then
            helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
        else
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        end
    else
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.AnimState:SetBank("winona_battery_placement")
            inst.helper.AnimState:SetBuild("winona_battery_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

            inst.helper.entity:SetParent(inst.entity)

            if placerinst ~= nil and recipename ~= "winona_battery_low" and recipename ~= "winona_battery_high" and recipename ~= "kk_workspace" then
                inst.helper:AddComponent("updatelooper")
                inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                inst.helper.placerinst = placerinst
                OnUpdatePlacerHelper(inst.helper)
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end
--------------------------------------------------------------------------
local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif string.sub(item.prefab, -3) ~= "gem" then
        return false, "NOTGEM"
    elseif string.sub(item.prefab, -11, -4) == "precious" then
        return false, "WRONGGEM"
    end
    return true
end

local function OnGemGiven(inst, giver, item)
    if #inst._gems < GEMSLOTS then
        table.insert(inst._gems, item.prefab)
        SetGem(inst, #inst._gems, item.prefab)
        if #inst._gems >= GEMSLOTS then
            inst.components.trader:Disable()
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    end

    local delta = inst.components.fueled.maxfuel / GEMSLOTS
    if inst.components.fueled:IsEmpty() then
        --prevent battery level flicker by subtracting a tiny bit from initial fuel
        delta = delta - .000001
    else
        local final = inst.components.fueled.currentfuel + delta
        local amtpergem = inst.components.fueled.maxfuel / GEMSLOTS
        local curgemamt = final - math.floor(final / amtpergem) * amtpergem
        if curgemamt < 3 then
            --prevent new gem from shattering within 3 seconds of socketing
            delta = delta + 3 - curgemamt
        end
    end
    inst.components.fueled:DoDelta(delta)

    if not inst.components.fueled.consuming then
        inst.components.fueled:StartConsuming()
        BroadcastCircuitChanged(inst)
        if inst.components.circuitnode:IsConnected() then
            StartBattery(inst)
        end
    end

    onhit(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
end
--------------------------------------------------------------------------
local function OnSave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") or nil
    data.gems = #inst._gems > 0 and inst._gems or nil
end

local function OnLoad(inst, data, ents)
    if data ~= nil then
        if data.gems ~= nil and #inst._gems < GEMSLOTS then
            for i, v in ipairs(data.gems) do
                table.insert(inst._gems, v)
                SetGem(inst, #inst._gems, v)
                if #inst._gems >= GEMSLOTS then
                    inst.components.trader:Disable()
                    break
                end
            end
            ShatterGems(inst, math.ceil(inst.components.fueled:GetCurrentSection() / LEVELS_PER_GEM))
        end
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        elseif not inst.components.fueled:IsEmpty() then
            if not inst.components.fueled.consuming then
                inst.components.fueled:StartConsuming()
                BroadcastCircuitChanged(inst)
            end
        end
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineering")
end

local function OnLoadPostPass(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        OnInit(inst)
    end
end

local function OnUseDelta(inst, data)
    if not data then
        return
    end
    local percent = data.percent
    if percent <= 0 then
        inst.Light:Enable(false)
    else
        inst.Light:Enable(true)
    end
end

local function OnCoating(inst, painter, coating)
    inst.AnimState:PlayAnimation("changeskin")
    inst.AnimState:PushAnimation("idle", true)
    if painter ~= nil and painter.sg ~= nil and painter.sg:HasState("kk_coating") then
        painter.sg:GoToState("kk_coating")
    end
end
--------------------------------------------------------------------------
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("kk_workspace")
    inst.AnimState:SetBuild("kk_workspace")
    inst.AnimState:PlayAnimation("idle", true)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("kk_workspace.tex")

    inst:AddTag("kk_workspace")
    inst:AddTag("structure")
    inst:AddTag("prototyper")
    inst:AddTag("engineeringbattery")
    inst:AddTag("gemsocket")

    inst:AddTag("trader")

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
        inst.components.deployhelper:AddRecipeFilter("kk_workspace")
        inst.components.deployhelper:AddRecipeFilter("kk_dormancy")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
    inst.Light:Enable(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("updatelooper")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetSections(NUM_LEVELS)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
    inst.components.fueled.maxfuel = TUNING.WINONA_BATTERY_HIGH_MAX_FUEL_TIME
    inst.components.fueled.fueltype = FUELTYPE.MAGIC

    inst:ListenForEvent("percentusedchange", OnUseDelta)

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.KK_WORKSPACE
    inst.components.prototyper.onactivate = onactivate

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false

    inst:AddComponent("battery")
    inst.components.battery.canbeused = CanBeUsedAsBattery
    inst.components.battery.onused = UseAsBattery

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.burnable.ignorefuel = true

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst.OnCoating = OnCoating

    inst._gems = {}
    inst._batterytask = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)
    UpdateCircuitPower(inst)

    return inst
end

local function placer_postinit_fn(inst)
    local placer2 = CreateEntity()

    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    placer2.AnimState:SetBank("kk_workspace")
    placer2.AnimState:SetBuild("kk_workspace")
    placer2.AnimState:PlayAnimation("idle", true)
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
end

return Prefab("kk_workspace", fn, assets),
       MakePlacer("kk_workspace_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)