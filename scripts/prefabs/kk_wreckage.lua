local assets =
{
    Asset("ANIM", "anim/kk_wreckage.zip"),
}

local function OnHammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function OnHit(inst, worker, workLeft)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:DoTaskInTime(3.5,function()
        MakeObstaclePhysics(inst, .5)
    end)

    inst.AnimState:SetBank("kk_wreckage")
    inst.AnimState:SetBuild("kk_wreckage")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("kk_wreckage.tex")

    inst:AddTag("kk_wreckage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("chess_junk")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetMaxWork(6)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    MakeHauntable(inst)

    return inst
end

local function repaire()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("kk_repaire")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.OnBuiltFn = function(inst, builder)
        local fx = nil
        local delay = 0
        if builder:HasTag("k_k") then
            local workspace = FindClosestEntity(builder, 5, true, {"kk_workspace"}, {"burnt"}, nil)
            if workspace and workspace.OnCoating ~= nil then
                workspace.OnCoating(workspace, builder, inst)
                delay = 30*FRAMES
            else
                fx = "spawn_fx_medium"
            end
            builder.kk_state = "repaired"
            builder:PushEvent("kk_statechanged", {onload=false, repaire=true, fx=fx, delay=delay})
        end
        inst:Remove()
    end
    inst:DoTaskInTime(1,function() inst:Remove() end)

    return inst
end

local function derepaire()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("kk_derepaire")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.OnBuiltFn = function(inst, builder)
        local fx = nil
        local delay = 0
        if builder:HasTag("k_k") then
            fx = "collapse_small"
            builder.kk_state = "normal"
            builder:PushEvent("kk_statechanged", {onload=false, fx=fx, delay=delay, lightoff=true})
            if builder.components.inventory ~= nil then
                for k,v in pairs({"kk_mechanical_leg","kk_mechanical_eye","kk_ironplate"}) do
                    if math.random() <= 2/3 then
                        builder.components.inventory:GiveItem(SpawnPrefab(v), nil, inst:GetPosition())
                    end
                end
            else
                for k,v in pairs({"kk_mechanical_leg","kk_mechanical_eye","kk_ironplate"}) do
                    if math.random() <= 2/3 then
                        SpawnPrefab(v).Transform:SetPosition(inst.Transform:GetWorldPosition())
                    end
                end
            end
        end
        inst:Remove()
    end
    inst:DoTaskInTime(1,function() inst:Remove() end)

    return inst
end

local function maintain()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("kk_maintain")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.OnBuiltFn = function(inst, builder)
        inst:Remove()
    end
    inst:DoTaskInTime(1,function() inst:Remove() end)

    return inst
end

local function point()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("kk_wreckage_point")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.SetSkeletonDescription = function() end
    inst.SetSkeletonAvatarData = function() end
    inst.Decay = function() end

    inst:DoTaskInTime(0,function() inst:Remove() end)

    return inst
end

return Prefab("kk_wreckage", fn, assets),
       MakePlacer("kk_wreckage_placer", "kk_wreckage", "kk_wreckage", "idle"),
       Prefab("kk_repaire", repaire, assets),
       Prefab("kk_derepaire", derepaire, assets),
       Prefab("kk_maintain", maintain, assets),
       Prefab("kk_wreckage_point", point)