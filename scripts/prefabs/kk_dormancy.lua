local assets =
{
    Asset("ANIM", "anim/kk_dormancy.zip"),
}

local PLACER_SCALE = 1.5

local function CreatePlacerBatteryRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    return inst
end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_spotlight_placement")
    inst.AnimState:SetBuild("winona_spotlight_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    CreatePlacerBatteryRing().entity:SetParent(inst.entity)

    return inst
end

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
            if recipename == "kk_dormancy" then
                inst.helper = CreatePlacerRing()
                inst.helper.entity:SetParent(inst.entity)
            else
                inst.helper = CreatePlacerBatteryRing()
                inst.helper.entity:SetParent(inst.entity)
                if placerinst ~= nil and (recipename == "winona_battery_low" or recipename == "winona_battery_high" or recipename == "kk_workspace") then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnBuilt2(inst)
    inst:RemoveEventCallback("animover", OnBuilt2)
    if not inst:HasTag("burnt") then
        inst.components.circuitnode:ConnectTo("engineeringbattery")
    end
end

local function onbuilt(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.AnimState:PlayAnimation("build")
    inst.AnimState:PushAnimation("nopower", true)
    inst:ListenForEvent("animover", OnBuilt2)
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("standstill", true)
    end
end

local function onignite(inst)
    inst.AnimState:PlayAnimation("close_pre")
    inst.AnimState:PushAnimation("burning", true)
    if inst:HasTag("candormancy") then
        inst:RemoveTag("candormancy")
    end
end

local function onextinguish(inst)
    if inst.AnimState:IsCurrentAnimation("burning") then
        inst.AnimState:PlayAnimation("shrink")
        inst.AnimState:PushAnimation("standstill", true)
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

    inst:RemoveComponent("updatelooper")
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
end

local function NotBurningOrBurnt(inst)
    return not inst:HasTag("burnt") and not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
end

local function onfar(inst)
    if NotBurningOrBurnt(inst) then
        if not inst.AnimState:IsCurrentAnimation("nopower") and (not inst.components.kk_dormancy or inst.components.kk_dormancy:GetUser() == nil) then
            inst.AnimState:PlayAnimation("shrink")
            inst.AnimState:PushAnimation("standstill", true)

            inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
        end
        if not inst:IsPowered() then
            inst.AnimState:PushAnimation("nopower", true)
        end
    end
    if inst:HasTag("candormancy") then
        inst:RemoveTag("candormancy")
    end
end

local function SetCanBeUsed(inst)
    inst:RemoveEventCallback("animover", SetCanBeUsed)
    if NotBurningOrBurnt(inst) then
        if not inst:HasTag("candormancy") then
            inst:AddTag("candormancy")
        end
    end
end

local function onnear(inst)
    if NotBurningOrBurnt(inst) then
        if not (inst.AnimState:IsCurrentAnimation("close_pre") or inst.AnimState:IsCurrentAnimation("close")) and inst:IsPowered() then
            inst.AnimState:PlayAnimation("close_pre")
            inst.AnimState:PushAnimation("close", true)

            inst:ListenForEvent("animover", SetCanBeUsed)
        end
        if not inst:IsPowered() then
            inst.AnimState:PushAnimation("nopower", true)
        end
    end
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function OnSave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    else
        data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil
    end
end

local function OnLoad(inst, data, ents)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    else
        if data ~= nil and data.power ~= nil then
            inst:AddBatteryPower(math.max(2 * FRAMES, data.power / 1000))
        end
        inst.components.circuitnode:ConnectTo(nil)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
end

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
        or (inst._powertask == nil and "OFF")
        or nil
end

local function PowerOff(inst)
    inst._powertask = nil
    if NotBurningOrBurnt(inst) then
        if inst.AnimState:IsCurrentAnimation("close") then
            inst.AnimState:PlayAnimation("shrink")
        end
        inst.AnimState:PushAnimation("nopower", true)
    end
    if inst:HasTag("powered") then
        inst:RemoveTag("powered")
    end
    if inst.components.kk_dormancy ~= nil then
        local user = inst.components.kk_dormancy:GetUser()
        if user ~= nil and user.sg ~= nil and user.sg:HasState("idle") then
            user.sg:GoToState("idle")
        end
        inst.components.kk_dormancy:Stop()
    end
end

local function AddBatteryPower(inst, power)
    local remaining = inst._powertask ~= nil and GetTaskRemaining(inst._powertask) or 0
    if power > remaining then
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
        else
            if inst.AnimState:IsCurrentAnimation("nopower") then
                inst.AnimState:PlayAnimation("idle")
                inst.AnimState:PushAnimation("standstill", true)
            end
        end
        inst._powertask = inst:DoTaskInTime(power, PowerOff)
        if not inst:HasTag("powered") then
            inst:AddTag("powered")
        end
    end
end

local function IsPowered(inst)
    return inst._powertask ~= nil
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
    --Notify other connected batteries
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
end

local function OnConnectCircuit(inst)--, node)
    --inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:PushAnimation("standstill", true)
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("nopower", true)
    end
    if inst.components.circuitnode:IsConnected() then
        OnCircuitChanged(inst)
    end
end

local function randomanim(inst)
    if IsPowered(inst) and inst.AnimState:IsCurrentAnimation("standstill") then
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:PushAnimation("standstill", true)
    end
    inst:DoTaskInTime(6 + math.random() * 5, randomanim)
end

local function nopowersound(inst)
    if not IsPowered(inst) then
        for _, v in ipairs(AllPlayers) do
            if not v:HasTag("playerghost") and v.entity:IsVisible() and inst:IsNear(v, 2) then
                inst.SoundEmitter:PlaySound("WX_rework/scanner/ping")
            end
        end
    end
    inst:DoTaskInTime(1, nopowersound)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("kk_dormancy")
    inst.AnimState:SetBuild("kk_dormancy")
    inst.AnimState:PlayAnimation("nopower", true)

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("kk_dormancy.tex")

    inst:AddTag("kk_dormancy")
    inst:AddTag("engineering")
    inst:AddTag("structure")
    inst:AddTag("prototyper")

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

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    randomanim(inst)
    nopowersound(inst)

    inst:AddComponent("updatelooper")
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("kk_dormancy")

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2, 3)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    inst.components.playerprox.period = 1 * FRAMES

    inst:DoTaskInTime(.1, function()
        if inst.components.playerprox ~= nil then
            inst.components.playerprox:ForceUpdate()
        end
    end)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst:ListenForEvent("onignite", onignite)
    inst:ListenForEvent("onextinguish", onextinguish)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.AddBatteryPower = AddBatteryPower
    inst.IsPowered = IsPowered

    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

local function placer_postinit_fn(inst)
    --[[local placer2 = CreatePlacerBatteryRing()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)]]

    local placer2 = CreateEntity()

    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    placer2.AnimState:SetBank("kk_dormancy")
    placer2.AnimState:SetBuild("kk_dormancy")
    placer2.AnimState:PlayAnimation("idle", true)
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
end

return Prefab("kk_dormancy", fn, assets),
       MakePlacer("kk_dormancy_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)