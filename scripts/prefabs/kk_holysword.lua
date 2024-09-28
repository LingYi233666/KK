local assets =
{
    Asset("ANIM", "anim/kk_holysword.zip"),
}

local function OnAttack(inst, data)
    local target = data.target
    if not target or not target:HasTag("chess") then
        return
    end

    target.kk_must_drop = true

    if target.kk_drop_fn ~= nil then
        target.kk_drop_fn:Cancel()
    end

    target.kk_drop_fn = target:DoTaskInTime(.5, function()
        target.kk_must_drop = nil
    end)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "kk_holysword", "swap_holysword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:ListenForEvent("onattackother", OnAttack, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst:RemoveEventCallback("onattackother", OnAttack, owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kk_holysword")
    inst.AnimState:SetBuild("kk_holysword")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")
    inst:AddTag("kk_holysword")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small", nil, .75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(function(inst, attacker, target)
        if target:HasTag("chess") then
            return 60
        end
        return 40
    end)
    -------
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = KK_IMAGES

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(200)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, 1)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("kk_holysword", fn, assets)