local assets =
{
    Asset("ANIM", "anim/kk_light.zip"),
}


local function lightfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --inst.AnimState:SetBank("kk_light")
    --inst.AnimState:SetBuild("kk_light")
    --inst.AnimState:PlayAnimation("idle")

    inst:AddTag("FX")
    
    inst.Light:SetIntensity(0.6)
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(.9)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("kk_light", lightfn, assets)