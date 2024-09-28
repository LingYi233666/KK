local assets =
{
    Asset("ANIM", "anim/kk_cane.zip"),
    Asset("ANIM", "anim/kk_cane_attack.zip"),
}

local CANE_DMG = 45

local function cane_disable(inst)
    if inst.updatetask then
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end
end

local FOLLOWER_ONEOF_TAGS = {"chess"}
local FOLLOWER_CANT_TAGS = {"player"}

local function cane_update(inst)
    if not inst.kk_on or (inst.components.fueled and inst.components.fueled:GetPercent() <= 0) then
        return
    end
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then
        local x,y,z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 20, nil, FOLLOWER_CANT_TAGS, FOLLOWER_ONEOF_TAGS)
        for k,v in pairs(ents) do
            if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) then
                owner.components.leader:AddFollower(v)
            end
        end
        for k,v in pairs(owner.components.leader.followers) do
            if k.components.follower and k:HasTag("chess") then
                k.components.follower:AddLoyaltyTime(1.2)
            end
        end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "kk_cane", "swap_kk_cane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.fueled ~= nil then
        if not inst._kk_cane_light then
            inst._kk_cane_light = SpawnPrefab("kk_cane_light")
            inst._kk_cane_light.entity:SetParent(owner.entity)
        end
        if inst.components.fueled:GetPercent() <= 0 then
            inst._kk_cane_light.Light:Enable(false)
        else
            if inst.kk_on then
                inst.components.fueled:StartConsuming()
                inst._kk_cane_light.Light:Enable(true)
            end
        end
    end

    owner:AddTag("kk_chess_leader")
    if owner:HasTag("k_k") then
        inst.updatetask = inst:DoPeriodicTask(1, cane_update, 1)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    if inst._kk_cane_light then
        inst._kk_cane_light:Remove()
        inst._kk_cane_light = nil
    end

    owner:RemoveTag("kk_chess_leader")
    cane_disable(inst)
end

local function onequiptomodel(inst, owner)
    --if owner then
    --    inst.components.fueled:StopConsuming()
    --end

    cane_disable(inst)
end

local function onattack(inst, attacker, target)
end

local function OnUseDelta(inst, data)
    if not data then
        return
    end
    local percent = data.percent
    local dmg = inst.components.weapon and inst.components.weapon.damage
    if percent > 0 then
        if dmg ~= CANE_DMG then
            inst.components.weapon:SetDamage(CANE_DMG)
            inst.components.weapon:SetRange(8, 10)
            inst.components.weapon:SetProjectile("kk_cane_attack")
            inst.components.weapon:SetElectric()
        end
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            if inst.components.fueled ~= nil and not inst.components.fueled.consuming then
                inst.components.fueled:StartConsuming()
            end
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
            if owner and not owner:HasTag("k_k") then
                owner:AddTag("kk_chess_leader")
            end
        end
        if inst._kk_cane_light then
            inst._kk_cane_light.Light:Enable(true)
        end
        inst:AddTag("rangedweapon")
    else
        if dmg ~= TUNING.SPEAR_DAMAGE then
            inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
            inst.components.weapon:SetRange(nil)
            inst.components.weapon:SetProjectile(nil)
            inst.components.weapon.stimuli = nil
        end
        if inst._kk_cane_light then
            inst._kk_cane_light.Light:Enable(false)
        end
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
            if owner and not owner:HasTag("k_k") then
                owner:RemoveTag("kk_chess_leader")
            end
        end
        inst:RemoveTag("rangedweapon")
    end
end

local function SelectPoint(staff, target, pos)
    local owner = staff.components.inventoryitem and staff.components.inventoryitem.owner
    if owner and owner.components.leader then
        for k,v in pairs(owner.components.leader.followers) do
            if k.components.follower and k:HasTag("chess") then
                if k.components.combat then
                    k.components.combat:DropTarget()
                end
                if k.components.knownlocations then
                    k.components.knownlocations:RememberLocation("home", pos)
                end
                --if k.components.locomotor then
                --    k.components.locomotor:GoToPoint(pos)
                --end
            end
        end
        if not owner.kk_cane_pos or not owner.kk_cane_pos:IsValid() then
            owner.kk_cane_pos = SpawnPrefab("kk_cane_pos")
        end
        if owner.kk_cane_pos then
            owner.kk_cane_pos.Transform:SetPosition(pos:Get())
        end
    end
end

local function GetStatus(inst)
    return (inst.components.fueled ~= nil and inst.components.fueled:GetPercent() <= 0 and "OFF")
        or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("kk_cane.tex")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kk_cane")
    inst.AnimState:SetBuild("kk_cane")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("kk_cane")
    inst:AddTag("kk_chargeable")
    
    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small", nil, .75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.kk_on = true

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(CANE_DMG)
    inst.components.weapon:SetRange(8, 10)
    --inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetProjectile("kk_cane_attack")
    inst.components.weapon:SetElectric()
    -------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(function(inst)
        if inst.kk_on then
            inst.kk_on = false
            OnUseDelta(inst, {percent=0})
            if inst.components.fueled ~= nil then
                inst.components.fueled:StopConsuming()
            end
        else
            inst.kk_on = true
            OnUseDelta(inst, {percent=(inst.components.fueled ~= nil and inst.components.fueled:GetPercent() or 0)})
            if inst.components.fueled ~= nil then
                inst.components.fueled:StartConsuming()
            end
        end
        inst:DoTaskInTime(FRAMES, function() inst.components.useableitem:StopUsingItem() end)
    end)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(SelectPoint)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canuseonpoint_water = false
    inst.components.spellcaster.quickcast = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = KK_IMAGES

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(TUNING.NIGHTSTICK_FUEL)
    --inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    inst:ListenForEvent("percentusedchange", OnUseDelta)

    MakeHauntableLaunch(inst)

    return inst
end

local function lightfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    
    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function cane_attack()
    local inst = SpawnPrefab("bishop_charge")

    inst.AnimState:SetBank("kk_cane_attack")
    inst.AnimState:SetBuild("kk_cane_attack")

    if inst.components.projectile ~= nil then
        inst.components.projectile:SetLaunchOffset(Vector3(0,2,0))
    end

    return inst
end

local function posfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("kk_cane", fn, assets),
       Prefab("kk_cane_light", lightfn, assets),
       Prefab("kk_cane_attack", cane_attack, assets),
       Prefab("kk_cane_pos", posfn, assets)