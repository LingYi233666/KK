local assets =
{
    Asset("ANIM", "anim/shadow_rook.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("shadow_rook")
    inst.AnimState:SetBuild("shadow_rook")
    inst.AnimState:PlayAnimation("Transform")

    inst.AnimState:HideSymbol("base")
    inst.AnimState:HideSymbol("top_head")
    inst.AnimState:HideSymbol("bottom_head")
    inst.AnimState:HideSymbol("big_horn")
    inst.AnimState:HideSymbol("mouth_space")
    inst.AnimState:HideSymbol("small_horn_lft")
    inst.AnimState:HideSymbol("small_horn_rgt")

    local s = 0.6
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetTime(1.9)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("kk_nightmare_transform_fx", fn, assets)
