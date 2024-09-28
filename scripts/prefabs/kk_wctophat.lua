local assets =
{
    Asset("ANIM", "anim/wctophat.zip"),
}

local function onequip(inst, owner)
    --local skin_build = inst:GetSkinBuild()
    --if skin_build ~= nil then
        --owner:PushEvent("equipskinneditem", inst:GetSkinName())
        --owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, fname)
    --else
        owner.AnimState:OverrideSymbol("swap_hat", "wctophat", "swap_hat"..(math.random()<.95 and "_2" or ""))
    --end
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
        owner.AnimState:Show("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner)
    --local skin_build = inst:GetSkinBuild()
    --if skin_build ~= nil then
        --owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    --end

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onstartusing(inst, doer)
    if inst.components.container ~= nil and doer:HasTag("k_k") then
        inst.components.container:Open(doer)
    end
end

local function onstopusing(inst, doer)
    if inst.components.container ~= nil then
        inst.components.container:Close(doer)
    end
end

local function OnSlotDirty(inst)
    inst:DoTaskInTime(.1, function()
        if inst._upgrade:value() and inst.replica.container ~= nil then
            inst.replica.container:WidgetSetup("kk_wctophat_up")
        end
    end)
end

local function OnUpgrade(inst, performer, upgraded_from_item)
    local numupgrades = inst.components.upgradeable.numupgrades
    if numupgrades == 1 then
        if inst.components.container ~= nil then
            inst.components.container:WidgetSetup("kk_wctophat_up")
        end
        if upgraded_from_item then
            local x, y, z = inst.Transform:GetWorldPosition()
            local fx = SpawnPrefab("chestupgrade_stacksize_fx")
            fx.Transform:SetPosition(x, y, z)
        end
        inst._upgrade:set(true)
    end
    inst.components.upgradeable.upgradetype = nil
end

local function OnDepleted(inst)
    if inst.components.container then
        inst.components.container:DropEverything(nil, true)
    end
    inst:Remove()
end

local function OnSave(inst, data)
    if inst.components.upgradeable.numupgrades == 1 then
        data.upgrade = true
    end
end

local function OnPreLoad(inst, data)
    if data.upgrade then
        if inst.components.container ~= nil then
            inst.components.container:WidgetSetup("kk_wctophat_up")
        end
    end
end

local function OnLoad(inst, data)
    if data.upgrade then
        inst.components.upgradeable.upgradetype = nil
        inst._upgrade:set(true)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wctophat")
    inst.AnimState:SetBuild("wctophat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("kk_wctophat")
    inst:AddTag("hat")
    inst:AddTag("HASHEATER")
    inst:AddTag("waterproofer")
    inst:AddTag("goggles")
    inst:AddTag("fridge")

    MakeInventoryFloatable(inst)
    inst.components.floater:SetBankSwapOnFloat(false, nil, { bank = "wctophat", anim = "anim" })
    inst.components.floater:SetSize("med")
    inst.components.floater:SetVerticalOffset(0.1)
    inst.components.floater:SetScale(0.65)

    inst._upgrade = net_bool(inst.GUID, "kk_wctophat._upgrade", "kk_upgrade_dirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("kk_upgrade_dirty", OnSlotDirty)
        inst.OnEntityReplicated = OnSlotDirty
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = KK_IMAGES

    local GetGrandOwner_old = inst.components.inventoryitem.GetGrandOwner
    inst.components.inventoryitem.GetGrandOwner = function(self, ...)
        if KK_GetSourceFile() == "magician" then
            return inst
        end
        return GetGrandOwner_old(self, ...)
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("kk_wctophat")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.canbeopened = false

    local IsOpenedBy_old = inst.components.container.IsOpenedBy
    inst.components.container.IsOpenedBy = function(self, ...)
        if KK_GetSourceFile() == "magician" then
            return true
        end
        return IsOpenedBy_old(self, ...)
    end

    inst:AddComponent("magiciantool")
    inst.components.magiciantool:SetOnStartUsingFn(onstartusing)
    inst.components.magiciantool:SetOnStopUsingFn(onstopusing)

    local upgradeable = inst:AddComponent("upgradeable")
    upgradeable.upgradetype = UPGRADETYPES.CHEST
    upgradeable:SetOnUpgradeFn(OnUpgrade)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE --[[MAGIC]]
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME*20)
    inst.components.fueled:SetDepletedFn(OnDepleted)
    --inst.components.fueled.no_sewing = true

    inst:AddComponent("heater")
    inst.components.heater:SetThermics(false, true)
    inst.components.heater.equippedheat = TUNING.ICEHAT_COOLER

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.insulator:SetSummer()

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)    

    MakeHauntableLaunch(inst)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad

    return inst
end

local function percent()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = KK_IMAGES
    inst.components.inventoryitem:ChangeImageName("kk_wctophat")

    inst:DoTaskInTime(.1,function()
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.components.inventory.ignoresound = true
            owner.components.inventory:DropItem(inst, true)
            local wctophat = SpawnPrefab("kk_wctophat")
            wctophat.components.fueled:SetPercent(.2)
            owner.components.inventory:GiveItem(wctophat)
            owner.components.inventory.ignoresound = false
        end
        inst:Remove()
    end)

    return inst
end

return Prefab("kk_wctophat", fn, assets),
       Prefab("kk_wctophat_20_percent", percent, assets)