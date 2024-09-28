local assets =
{
    Asset("ANIM", "anim/kk_materials.zip"),
}

local function makematerial(name, commonfn, masterfn)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("kk_materials")
        inst.AnimState:SetBuild("kk_materials")
        inst.AnimState:PlayAnimation(name)

        inst:AddTag("kk_materials")
        inst:AddTag("kk_"..name)

        MakeInventoryFloatable(inst, "small", nil, .75)
        inst.components.floater:SetSwapData({anim = name})

        if commonfn then
            commonfn(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -------
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = KK_IMAGES

        if masterfn then
            masterfn(inst)
        end

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("kk_"..name, fn, assets)
end

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
    DefaultBurnFn(inst)
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    DefaultExtinguishFn(inst)
end

local function OnExplodeFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function fix(target, pct)
    if target.components.finiteuses ~= nil then
        local percent = target.components.finiteuses:GetPercent()
        target.components.finiteuses:SetPercent(math.min(percent+pct, 1))
    elseif target.components.fueled ~= nil then
        local percent = target.components.fueled:GetPercent()
        target.components.fueled:SetPercent(math.min(percent+pct, 1))  
    end
end

local function OnChargeFn(inst, user, target)
    if not target then return end
    if target.prefab == "kk_cane" then
        fix(target, 1/3)
    else
        fix(target, .2)
    end
end

local function battery_masterfn(inst)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(5)
    inst.components.finiteuses:SetUses(5)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("kk_charger")
    inst.components.kk_charger.onchargefn = OnChargeFn

    MakeSmallBurnable(inst, 3 + math.random() * 3)
    MakeSmallPropagator(inst)

    inst.components.burnable:SetOnBurntFn(nil)
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE
end

local function common_masterfn(inst)
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
end

local materials = {}
local materials_data = {
    battery = {
        commonfn=function(inst)
            inst:AddTag("kk_charger")
        end, 
        masterfn=battery_masterfn
    },
    ironplate = {masterfn=common_masterfn},
    mechanical_eye = {masterfn=common_masterfn},
    mechanical_leg = {masterfn=common_masterfn},
}

for k,v in pairs(materials_data) do
    table.insert(materials, makematerial(k, v.commonfn, v.masterfn))
end

return unpack(materials)