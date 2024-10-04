local assets =
{
    Asset("ANIM", "anim/kk_shadow_fx.zip"),
}


local function fx()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("kk_shadow_fx")
    inst.AnimState:SetBuild("kk_shadow_fx")
    inst.AnimState:PlayAnimation("anim", true)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetMultColour(1, 1, 1, .6)

    inst:AddTag("FX")

    inst.Light:SetRadius(1)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.9)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, function() if inst.parent == nil then inst:Remove() end end)

    return inst
end

return Prefab("kk_shadow_fx", fx, assets)
