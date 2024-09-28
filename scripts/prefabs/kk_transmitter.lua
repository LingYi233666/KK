local assets =
{
    Asset("ANIM", "anim/kk_transmitter.zip"),
}

local function GetSpawnPoint(pt)
    if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
        pt = FindNearbyLand(pt, 1) or pt
    end
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 25, 12, true)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function on_anim_over(inst)
    local pt = inst:GetPosition()
    local chesslist = {"knight","bishop","rook"}

    local num = math.random(7,8)
    for k=1,num do
        local pos = pt+Vector3(10*math.cos(360/num*k*DEGREES), 0, 10*math.sin(360/num*k*DEGREES))
        pos = GetSpawnPoint(pos)
        if pos ~= nil then
            local chess = SpawnPrefab(chesslist[math.random(#chesslist)])
            if chess ~= nil then
                chess.Physics:Teleport(pos:Get())
                chess:DoTaskInTime(.5, function(inst)
                    if chess.components.knownlocations ~= nil then
                        pt = pt+Vector3(2+math.cos(360/num*k*DEGREES), 0, 2+math.sin(360/num*k*DEGREES))
                        chess.components.knownlocations:RememberLocation("home", pt)
                    end
                end)

                SpawnPrefab("collapse_small").Transform:SetPosition(pos:Get())
            end
        end
    end

    inst:Remove()
end

local function OnActivate(inst, doer)
    inst.persists = false
    inst.entity:SetCanSleep(false)

    inst.AnimState:PlayAnimation("up")
    inst:ListenForEvent("animover", on_anim_over)

    inst.SoundEmitter:PlaySound("turnoftides/common/together/miniflare/launch")
    return true
end

local function on_dropped(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("kk_transmitter.tex")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kk_transmitter")
    inst.AnimState:SetBuild("kk_transmitter")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "small", nil, .75)

    inst:AddTag("kk_transmitter")

    inst:AddTag("donotautopick")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = KK_IMAGES

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.quickaction = true

    inst:ListenForEvent("ondropped", on_dropped)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("kk_transmitter", fn, assets)