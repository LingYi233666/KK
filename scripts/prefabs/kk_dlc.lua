local assets =
{
	Asset("ANIM", "anim/kk_dlc.zip"),
}

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "kk_dlc", "swap_weapon")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end


local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
end

local DESTROYSTUFF_CANT_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
local function hz(inst, doer, pos)
	if doer == nil or pos == nil then return false end
	local fx = SpawnPrefab("kk_fx1")
	local pc_x,pc_z =pos.x, pos.z
	fx.Transform:SetPosition(pc_x, pos.y, pc_z)
	local ents = TheSim:FindEntities(pc_x, pos.y, pc_z, 2.5, nil, DESTROYSTUFF_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and
            v.components.workable ~= nil and 
            v.components.workable:CanBeWorked() and
            v.components.workable.action ~= ACTIONS.NET then
            SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
            v.components.workable:Destroy(inst)
        end
		if v ~= doer and v.components.combat and doer.components.combat:CanTarget(v) and not doer.components.combat:IsAlly(v) then
			v.components.combat:GetAttacked(doer, 300)
		end
    end
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    for r = 2.5, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 2.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function OnLightning(inst)    
    if inst.components.finiteuses ~= nil and inst.components.finiteuses:GetPercent() < 1 then
        --local uses = math.min(1, inst.components.finiteuses:GetUses()+1, inst.components.finiteuses.total)
        --inst.components.finiteuses:SetUses(uses)
        inst.components.finiteuses:SetPercent(1)
    end
end

local function OnUseDelta(inst, data)
    if data and data.percent > 0 then
        inst.components.aoetargeting:SetEnabled(true)
    else
        inst.components.aoetargeting:SetEnabled(false)
    end
end

local function GetStatus(inst)
    return (inst.components.finiteuses ~= nil and inst.components.finiteuses:GetPercent() <= 0 and "OFF")
        or nil
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("kk_dlc")
	inst.AnimState:SetBuild("kk_dlc")
	inst.AnimState:PlayAnimation("anim")
	
	inst:AddTag("kk_dlc")
	inst:AddTag("hammer")
	--inst:AddTag("lightningrod")
    inst:AddTag("kk_chargeable")
    inst:AddTag("kk_aoespell")
    inst:AddTag("kk_canspell")

    inst.MiniMapEntity:SetIcon("kk_dlc.tex")
	
	MakeInventoryFloatable(inst, "med", nil, 0.75)
	inst.entity:SetPristine()
	
	inst:AddComponent("aoetargeting")
	--inst.components.aoetargeting:SetAlwaysValid(true) 
    inst.components.aoetargeting.allowriding = false
    inst.components.aoetargeting.reticule.reticuleprefab = "reticule_kk_dlc"  
    inst.components.aoetargeting.reticule.pingprefab = "reticuleping_kk_dlc" 
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn 
	--inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }  
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 } 
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetRange(3) 
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = KK_IMAGES
	
    inst:AddComponent("tool") 
    inst.components.tool:SetAction(ACTIONS.HAMMER) 
	inst.components.tool:SetAction(ACTIONS.MINE) 
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(5)
    inst.components.finiteuses:SetUses(5)
	--inst.components.finiteuses:SetOnFinished(inst.Remove)
	inst.components.finiteuses:SetConsumption(ACTIONS.CASTAOE, 1)
    inst.components.finiteuses:SetIgnoreCombatDurabilityLoss(true)
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(60) 
	
	inst:AddComponent("equippable")  
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("kk_aoespell")
	inst.components.aoespell = inst.components.kk_aoespell				 
	inst.components.aoespell:SFL_SetSpellFn(hz) 
	inst:RegisterComponentActions("aoespell")

	--inst:ListenForEvent("lightningstrike", OnLightning)
    inst:ListenForEvent("percentusedchange", OnUseDelta)
 
	MakeHauntableLaunch(inst)

	return inst
end

local function fx1()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sinkhole")
    inst.AnimState:SetBuild("antlion_sinkhole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
	inst.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre2")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:DoTaskInTime(3,function() inst:Remove() end)

    return inst
end

local function kk_dlc()
    local inst = SpawnPrefab("reticuleaoe")
    inst.AnimState:SetScale(1, 1)

    return inst
end

local function kk_dlc_ping()
    local inst = SpawnPrefab("reticuleaoeping")
    inst.AnimState:SetScale(1, 1)

    return inst
end

return Prefab("kk_dlc", fn, assets),
	   Prefab("kk_fx1", fx1),
       Prefab("reticule_kk_dlc", kk_dlc),
       Prefab("reticuleping_kk_dlc", kk_dlc_ping)