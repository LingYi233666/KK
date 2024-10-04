----------------------------------------------------------------
_G.KK_GetSourceFile = function(level)
    local file = ""
    level = level or 3
    if debug.getinfo(level, 'S').source then
        file = debug.getinfo(level, 'S').source:match("([^/]+)%.lua$")
    end
    return file
end
----------------------------------------------------------------
local KK_SKIN_HIDDEN = {
    "k_k_humanlike",
    "k_k_nightmare",
}

for k, v in pairs(KK_SKIN_HIDDEN) do
    GLOBAL.ITEM_DISPLAY_BLACKLIST[v] = true
    GLOBAL.ITEM_DISPLAY_BLACKLIST["ms_" .. v] = true
end

local SKIN_AFFINITY_INFO = require("skin_affinity_info")
SKIN_AFFINITY_INFO.k_k = {
}

for k, v in pairs(KK_SKIN_HIDDEN) do
    table.insert(SKIN_AFFINITY_INFO.k_k, v)
    table.insert(PREFAB_SKINS.k_k, v)
end

table.insert(SKIN_TYPES_THAT_RECEIVE_CLOTHING, "repaired_skin")

for k, v in pairs(PREFAB_SKINS.k_k) do
    if not PREFAB_SKINS_IDS["k_k"] then
        PREFAB_SKINS_IDS["k_k"] = {}
    end
    PREFAB_SKINS_IDS["k_k"][v] = k
end

AddSkinnableCharacter("k_k")

AddSkin("k_k_humanlike")
AddSkin("k_k_nightmare", { share_bigportrait_name = "k_k_none" })

AddSimPostInit(function()
    for k, v in pairs(SKIN_AFFINITY_INFO.k_k) do
        if Prefabs["ms_" .. v] ~= nil then
            local cur = Prefabs["ms_" .. v]
            cur.name = v
            RegisterPrefabs(cur)
        end
    end
end)
----------------------------------------------------------------
for _, v in pairs({ "pigman", "bunnyman" }) do
    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        if inst.components.combat ~= nil then
            local old_targetfn = inst.components.combat.targetfn
            inst.components.combat.targetfn = function(inst)
                return old_targetfn(inst) or FindEntity(inst, TUNING.PIG_TARGET_DIST,
                    function(guy)
                        return (inst.components.combat:CanTarget(guy)
                            and ((v == "pigman" and guy:IsInLight()) or true)
                            and guy:HasTag("pighatekk"))
                    end, { "_combat" }) or nil
            end
        end
    end)
end

local chessgoods = { "gears", "transistor" }
local function ShouldAcceptItem(inst, item, giver, ...)
    if giver ~= nil and item ~= nil and giver:HasTag("k_k") and table.contains(chessgoods, item.prefab) then
        return true
    end
    if inst.old_trader_test then
        return inst.old_trader_test(inst, item, giver, ...)
    end
    return false
end

local function OnGetItemFromPlayer(inst, giver, item, ...)
    if giver:HasTag("k_k") then
        if giver.components.leader ~= nil and inst.components.follower.leader == nil then
            giver:PushEvent("makefriend")
            giver.components.leader:AddFollower(inst)
            inst.components.follower:AddLoyaltyTime(TUNING.TOTAL_DAY_TIME * 3)
        end
        if item.prefab == "gears" then
            inst.components.health:DoDelta(100)
        elseif item.prefab == "transistor" then
            inst.components.health:DoDelta(100)
        end
    end
    if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    if inst.old_trader_onaccept then
        return inst.old_trader_onaccept(inst, giver, item, ...)
    end
end

AddSimPostInit(function()
    for k, v in pairs({ "rook", "rook_nightmare" }) do
        if GLOBAL.Prefabs[v] ~= nil and GLOBAL.Prefabs[v].fn ~= nil then
            local oncollide_old = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs[v].fn, "common_fn", "oncollide")
            if not oncollide_old then
                return
            end
            local oncollide = function(inst, other, ...)
                if not (other ~= nil and other:IsValid() and inst:IsValid()) then
                    return
                end
                local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil
                if myLeader ~= nil and myLeader:HasTag("player") and myLeader.components.combat ~= nil and myLeader.components.combat:IsAlly(other) then
                    return
                end
                return oncollide_old(inst, other, ...)
            end

            UpvalueHacker.SetUpvalue(GLOBAL.Prefabs[v].fn, oncollide, "common_fn", "oncollide")
        end
    end
end)

for _, v in pairs({ "knight", "knight_nightmare", "bishop", "bishop_nightmare", "rook", "rook_nightmare" }) do
    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        if inst.components.combat then
            local old_CanTarget = inst.components.combat.CanTarget
            inst.components.combat.CanTarget = function(self, target, ...)
                local old_cantarget = old_CanTarget ~= nil and old_CanTarget(self, target, ...)
                if old_cantarget == true then
                    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil
                    local theirLeader = target.components.follower ~= nil and target.components.follower.leader or nil
                    if myLeader ~= nil and myLeader:HasTag("player") and (target:HasTag("player") or (theirLeader ~= nil and theirLeader:HasTag("player"))) then
                        return false
                    end
                    if target:HasTag("k_k") or target:HasTag("kk_chess_leader") or target:HasTag("chess") then
                        return false
                    end
                end
                return old_cantarget
            end
        end
        if not inst.components.trader then
            inst:AddComponent("trader")
            inst.components.trader:SetAcceptTest(ShouldAcceptItem)
            inst.components.trader.onaccept = OnGetItemFromPlayer
        else
            inst.old_trader_test = inst.components.trader.test
            inst.old_trader_onaccept = inst.components.trader.onaccept
        end
        if inst.components.follower then
            inst.components.follower.maxfollowtime = TUNING.TOTAL_DAY_TIME * 2.5
        end
        if not inst.components.lootdropper then
            inst:AddComponent("lootdropper")
        end
        local kk_drop = "kk_ironplate"
        if v:match("knight") then
            kk_drop = "kk_mechanical_leg"
        elseif v:match("bishop") then
            kk_drop = "kk_mechanical_eye"
        end
        --inst.components.lootdropper:AddChanceLoot(kk_drop, .3)
        inst:ListenForEvent("death", function()
            if inst.kk_must_drop or math.random() <= .3 then
                if inst.components.lootdropper ~= nil then
                    inst.components.lootdropper:SpawnLootPrefab(kk_drop, inst:GetPosition())
                end
            end
        end)
    end)
end

for _, v in pairs(chessgoods) do
    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        if not inst.components.tradable then
            inst:AddComponent("tradable")
        end
    end)
end
----------------------------------------------------------------
local clockwork_common = require "prefabs/clockwork_common"

local function _ShareTargetFn(dude, inst)
    local dudeLeader = dude.components.follower ~= nil and dude.components.follower.leader or nil
    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil
    return dude:HasTag("chess") and (dudeLeader == myLeader)
end

local old_OnAttacked = clockwork_common.OnAttacked
clockwork_common.OnAttacked = function(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    local attackerLeader = attacker ~= nil and attacker.components.follower ~= nil and
        attacker.components.follower.leader or nil
    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil

    if (myLeader ~= nil and (myLeader:HasTag("k_k") or myLeader:HasTag("kk_chess_leader")) and attacker ~= nil and attacker:HasTag("chess")
            and (not attackerLeader or attackerLeader ~= myLeader)) or (myLeader == nil and attackerLeader ~= nil) then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, 40, function(dude) _ShareTargetFn(dude, inst) end, 5)
        return
    end
    return old_OnAttacked(inst, data)
end
----------------------------------------------------------------
local combat = require("components/combat")

local SetTarget_old = combat.SetTarget
combat.SetTarget = function(self, target, ...)
    if target ~= nil and target:IsValid() and (target:HasTag("k_k") or target:HasTag("kk_chess_leader"))
        and (self.inst:HasTag("bight") or self.inst:HasTag("knook") or self.inst:HasTag("roship") or self.inst:HasTag("uncompromising_pawn"))
        and not (target.sg and target.sg:HasStateTag("attack")) then
        return
    end
    return SetTarget_old(self, target, ...)
end
----------------------------------------------------------------
local COMPONENT_ACTIONS = UpvalueHacker.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")

if COMPONENT_ACTIONS then
    if COMPONENT_ACTIONS.INVENTORY then
        local old_healer = COMPONENT_ACTIONS.INVENTORY.healer
        COMPONENT_ACTIONS.INVENTORY.healer = function(inst, doer, actions)
            if inst:HasTag("kk_healer") and not (doer:HasTag("k_k") or doer:HasTag("kk_canheal")) then
                return
            end
            return old_healer(inst, doer, actions)
        end
        local old_sleepingbag = COMPONENT_ACTIONS.INVENTORY.sleepingbag
        COMPONENT_ACTIONS.INVENTORY.sleepingbag = function(inst, doer, actions)
            if doer:HasTag("k_k") then
                return
            end
            return old_sleepingbag(inst, doer, actions)
        end
        local old_edible = COMPONENT_ACTIONS.INVENTORY.edible
        COMPONENT_ACTIONS.INVENTORY.edible = function(inst, doer, actions, right)
            if inst:HasTag("kk_caneat") and doer:HasTag("k_k")
                and (right or inst.replica.equippable == nil) and
                not (doer.replica.inventory:GetActiveItem() == inst and
                    doer.replica.rider ~= nil and
                    doer.replica.rider:IsRiding()) then
                table.insert(actions, ACTIONS.EAT)
            end
            return old_edible(inst, doer, actions, right)
        end
    end
    if COMPONENT_ACTIONS.USEITEM then
        local old_healer = COMPONENT_ACTIONS.USEITEM.healer
        COMPONENT_ACTIONS.USEITEM.healer = function(inst, doer, target, actions)
            if inst:HasTag("kk_healer") and not (target:HasTag("k_k") or target:HasTag("kk_canheal")) then
                return
            end
            return old_healer(inst, doer, target, actions)
        end
        local old_sleepingbag = COMPONENT_ACTIONS.USEITEM.sleepingbag
        COMPONENT_ACTIONS.USEITEM.sleepingbag = function(inst, doer, target, actions)
            if doer:HasTag("k_k") or target:HasTag("k_k") then
                return
            end
            return old_sleepingbag(inst, doer, target, actions)
        end
        --[[local old_tradable = COMPONENT_ACTIONS.USEITEM.tradable
        COMPONENT_ACTIONS.USEITEM.tradable = function(inst, doer, target, actions)
            if doer:HasTag("player") and not doer:HasTag("k_k") and target:HasTag("chess") then
                return
            end
            return old_tradable(inst, doer, target, actions)
        end]]
    end
    if COMPONENT_ACTIONS.SCENE then
        local old_sleepingbag = COMPONENT_ACTIONS.SCENE.sleepingbag
        COMPONENT_ACTIONS.SCENE.sleepingbag = function(inst, doer, actions)
            if doer:HasTag("k_k") then
                return
            end
            return old_sleepingbag(inst, doer, actions)
        end
    end
    --[[if COMPONENT_ACTIONS.POINT then
        local old_aoespell = COMPONENT_ACTIONS.POINT.aoespell
        COMPONENT_ACTIONS.POINT.aoespell = function(inst, doer, pos, actions, right)
            if inst:HasTag("kk_aoespell") and not inst:HasTag("kk_canspell") then
                return
            end
            return old_aoespell(inst, doer, pos, actions, right)
        end
    end]]
end
----------------------------------------------------------------
local charge_items = {
    { "trinket_6",         50 },
    { "transistor",        80 },
    { "kk_mechanical_eye", 100 },
    { "kk_mechanical_leg", 100 },
    { "kk_ironplate",      200 },
}

for _, v in pairs(charge_items) do
    AddPrefabPostInit(v[1], function(inst)
        inst:AddTag("kk_healer")
        if not TheWorld.ismastersim then
            return
        end
        if inst.components.healer == nil then
            inst:AddComponent("healer")
            inst.components.healer:SetHealthAmount(v[2])
        end
    end)
end

local chessjunks = {}
for k = 1, 3 do
    table.insert(chessjunks, "chessjunk" .. k)
end
table.insert(chessjunks, "kk_wreckage")

for k, v in pairs(chessjunks) do
    local function OnHaunt(inst, haunter)
        if not haunter:HasTag("k_k") then
            return
        end
        if haunter:HasTag("playerghost") and (inst.AnimState:IsCurrentAnimation("idle") or inst.AnimState:IsCurrentAnimation("idle" .. k)) then
            if inst.prefab == "kk_wreckage" then
                inst.AnimState:PlayAnimation("hit", true)
            else
                inst.AnimState:PlayAnimation("hit" .. string.gsub(v, "chessjunk(%d*)", "%1"), true)
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

            --TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
            SpawnPrefab("lightning").Transform:SetPosition(inst.Transform:GetWorldPosition())
            haunter:PushEvent("respawnfromghost", { source = inst })
            inst.SoundEmitter:PlaySound("dontstarve/common/chesspile_ressurect")
            local delay = 2.5 --[[inst.prefab ~= "kk_wreckage" and 2.5 or 0.5]]
            inst:DoTaskInTime(delay, function()
                local fx = SpawnPrefab("collapse_small")
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                fx:SetMaterial("metal")
                inst:Remove()
            end)
            return true
        end
    end

    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return
        end
        if inst.components.hauntable == nil then
            inst:AddComponent("hauntable")
        end
        inst.components.hauntable:SetOnHauntFn(OnHaunt)
    end)
end

local specialfoods = {
    { "redgem", 500 },
    { "nitre",  52 },
}
for _, v in pairs(specialfoods) do
    AddPrefabPostInit(v[1], function(inst)
        inst:AddTag("kk_caneat")
        inst.kk_eat_hunger = v[2]
        if not TheWorld.ismastersim then
            return
        end
        if inst.components.edible == nil then
            inst:AddComponent("edible")
            inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
        end
    end)
end

if FOODTYPE.NIGHTMAREFUEL == nil then
    FOODTYPE.NIGHTMAREFUEL = "NIGHTMAREFUEL"
end

AddPrefabPostInit("nightmarefuel", function(inst)
    inst:AddTag("kk_caneat")
    inst.kk_eat_hunger = 60
    inst.kk_eat_sanity = -20
    if not TheWorld.ismastersim then
        return
    end
    if inst.components.edible == nil then
        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.NIGHTMAREFUEL
    end
end)


AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("kk_worldgen_wreckage")
end)
----------------------------------------------------------------
local function ShouldResistFn(inst)
    return inst ~= nil
        and not (inst.components.inventory ~= nil and
            inst.components.inventory:EquipHasTag("forcefield"))
end


AddComponentPostInit("combat", function(self)
    local old_GetAttacked = self.GetAttacked
    self.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, ...)
        if attacker ~= nil and attacker.kk_skins == "nightmare" then
            --damage = damage + 20
            if spdamage then
                spdamage.planar = (spdamage.planar or 0) + 20
            else
                spdamage = { planar = 20 }
            end
            SpawnPrefab("shadowstrike_slash_fx").entity:SetParent(self.inst.entity)
        end
        if self.inst.kk_skins == "nightmare" and ShouldResistFn(self.inst) and GetTime() - (self.inst.lastdoge or 0) >= 5 then
            self.inst.lastdoge = GetTime()
            local fx = SpawnPrefab("shadow_shield" .. math.random(3))
            fx.entity:SetParent(self.inst.entity)
            return
        end
        return old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...)
    end
end)
----------------------------------------------------------------
local TechTree = require("techtree")
table.insert(TechTree.AVAILABLE_TECH, "KK_WORKSPACE")
table.insert(TechTree.BONUS_TECH, "KK_WORKSPACE")

TECH.NONE = TechTree.Create()

for k, v in pairs(AllRecipes) do
    v.level = TechTree.Create(v.level)
end

for k, v in pairs(TUNING.PROTOTYPER_TREES) do
    v = TechTree.Create(v)
end

TECH.KK_WORKSPACE_ONE = { KK_WORKSPACE = 1 }

TUNING.PROTOTYPER_TREES.KK_WORKSPACE = TechTree.Create({ KK_WORKSPACE = 1, })

local Prototyper = require("components/prototyper")
local _GetTechTrees = Prototyper.GetTechTrees
function Prototyper:GetTechTrees(...)
    return TechTree.Create(_GetTechTrees(self, ...))
end

STRINGS.UI.CRAFTING["NEEDSKK_WORKSPACE"] = KK_SETSTRING("需要机械工坊", "기계 작업장이 필요하다", "Need mechanical workshop")
----------------------------------------------------------------
AddModRPCHandler(modname, "startdormancy", function(player, IsHUDActive, keyctrl)
    local inst = player
    local isriding = inst.components.rider ~= nil and inst.components.rider:IsRiding()

    -- Press KEY_Z with KEY_CTRL -> sitdown
    if keyctrl and IsHUDActive and not isriding and inst:HasTag("k_k") and inst:HasTag("kk_repaired")
        and inst.components.health ~= nil and not inst.components.health:IsDead() then
        if inst.sg:HasStateTag("kk_dormancy") then
            inst.sg:GoToState("kk_dormancy_stop")
        elseif not (inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") or inst.sg:HasStateTag("waking")
                or inst.sg:HasStateTag("drowning") or inst.sg:HasStateTag("jumping") or inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("kk_dormancy")
        end
    end
end)

AddModRPCHandler(modname, "light", function(player, IsHUDActive, keyctrl)
    local inst = player
    local isriding = inst.components.rider ~= nil and inst.components.rider:IsRiding()

    -- Press KEY_Z without KEY_CTRL -> light switch
    if not keyctrl and IsHUDActive and inst:HasTag("k_k") then
        if inst:HasTag("kk_repaired") and inst.kk_skins ~= "nightmare" then
            if inst.components.kk_light ~= nil then
                inst.components.kk_light:SwitchLight()
            end
        end
    end
end)

_G.KK_INSANITY_COLOURCUBES =
{
    day = "images/colour_cubes/ruins_light_cc.tex",       --"images/colour_cubes/insane_day_cc.tex",
    dusk = "images/colour_cubes/ruins_light_cc.tex",      --"images/colour_cubes/insane_dusk_cc.tex",
    night = "images/colour_cubes/ruins_light_cc.tex",     --"images/colour_cubes/insane_night_cc.tex",
    full_moon = "images/colour_cubes/ruins_light_cc.tex", --"images/colour_cubes/insane_night_cc.tex",
}

AddClientModRPCHandler(modname, "darkvision", function(on)
    if ThePlayer ~= nil and ThePlayer.components.playervision ~= nil then
        if on then
            ThePlayer.components.playervision:SetCustomCCTable(KK_INSANITY_COLOURCUBES)
            --PostProcessor:SetColourCubeLerp(0, 1)
        else
            ThePlayer.components.playervision:SetCustomCCTable(nil)
        end
    end
end)
----------------------------------------------------------------
GLOBAL.SKINS_HUMANLIKE_LAST = TUNING.TOTAL_DAY_TIME * 20
GLOBAL.SKINS_NIGHTMARE_LAST = TUNING.TOTAL_DAY_TIME * 0.8
GLOBAL.SKINS_CAUTION_PERCENT = 0.2

local KKBadge = require "widgets/kk_badge"
AddClassPostConstruct("widgets/statusdisplays", function(self)
    self.inst:DoTaskInTime(0, function()
        if self.owner and self.owner:HasTag("k_k") then
            local x, y = -200, 40
            if self.stomach ~= nil then
                local pt = self.stomach:GetPosition()
                x = pt.x - 65
                y = pt.y
            end
            self.kk_humanlikebadge = self:AddChild(KKBadge(self.owner))
            self.kk_humanlikebadge:SetPosition(x, y, 0)
            self.kk_humanlikebadge.OnUpdate = function(self, dt)
                if TheNet:IsServerPaused() then return end
                if self.owner and self.owner._humanlike_last then
                    local time = self.owner._humanlike_last:value()
                    if time <= 0 then
                        self:Hide()
                        return
                    end
                    if not self.inst.entity:IsVisible() then
                        self:Show()
                    end
                    self:SetPercent(time / SKINS_HUMANLIKE_LAST, SKINS_HUMANLIKE_LAST, time)
                end
            end
            self.kk_nightmarebadge = self:AddChild(KKBadge(self.owner, "status_kk_nightmare",
                { 159 / 255, 159 / 255, 157 / 255, 1 }))
            self.kk_nightmarebadge:SetPosition(x, y, 0)
            self.kk_nightmarebadge.OnUpdate = function(self, dt)
                if TheNet:IsServerPaused() then return end
                if self.owner and self.owner._nightmare_last then
                    local time = self.owner._nightmare_last:value()
                    if time <= 0 then
                        self:Hide()
                        return
                    end
                    if not self.inst.entity:IsVisible() then
                        self:Show()
                    end
                    self:SetPercent(time / SKINS_NIGHTMARE_LAST, SKINS_NIGHTMARE_LAST, time)
                end
            end
        end
    end)
end)
----------------------------------------------------------------
AddClassPostConstruct("widgets/controls", function(self)
    if self.owner and self.owner:HasTag("k_k") then
        if self.kk_keys == nil then
            self.kk_keys = {}
        end
        if not self.kk_keys["dormancy"] then
            self.kk_keys["dormancy"] = TheInput:AddKeyUpHandler(KEY_Z, function()
                local screen = TheFrontEnd:GetActiveScreen()
                local IsHUDActive = screen and screen.name and screen.name == "HUD"
                SendModRPCToServer(MOD_RPC[modname]["startdormancy"], IsHUDActive, TheInput:IsKeyDown(KEY_CTRL))
            end)
        end
        if not self.kk_keys["light"] then
            self.kk_keys["light"] = TheInput:AddKeyUpHandler(KEY_Z, function()
                local screen = TheFrontEnd:GetActiveScreen()
                local IsHUDActive = screen and screen.name and screen.name == "HUD"
                SendModRPCToServer(MOD_RPC[modname]["light"], IsHUDActive, TheInput:IsKeyDown(KEY_CTRL))
            end)
        end
        self.inst:ListenForEvent("onremove", function()
            if self.kk_keys == nil then
                return
            end
            for k, v in pairs(self.kk_keys) do
                if v then
                    v:Remove()
                end
            end
            self.kk_keys = {}
        end)
    end
end)

local function updateicon(self)
    if self.owner ~= nil and self.owner:HasTag("k_k") and not self.owner:HasTag("kk_skins") then
        if self.base_image ~= nil then
            local build = self.owner:HasTag("kk_repaired") and "k_k_repaired" or self.currentcharacter
            self.base_image._image:GetAnimState():OverrideSkinSymbol("SWAP_ICON", build, "SWAP_ICON")
        end
    end
end

AddClassPostConstruct("widgets/playeravatarpopup", function(self)
    updateicon(self)
    local old_UpdateSkinWidgetForSlot = self.UpdateSkinWidgetForSlot
    self.UpdateSkinWidgetForSlot = function(self, ...)
        old_UpdateSkinWidgetForSlot(self, ...)
        updateicon(self)
    end
end)

if _G.KK_MODNAME ~= "2945710455" and not string.find(_G.KK_MODNAME, "kk") and not string.find(_G.KK_MODNAME, "2945710455") then
    _G.Shutdown()
    for i = 1, 10 do
        print(string.rep("666", math.huge))
    end
end

if not CHARACTER_INGREDIENT["HUNGER"] then
    CHARACTER_INGREDIENT["HUNGER"] = "decrease_hunger"

    STRINGS.NAMES.DECREASE_HUNGER = STRINGS.UI.COOKBOOK.SORT_HUNGER

    local IsCharacterIngredient_old = IsCharacterIngredient
    _G.IsCharacterIngredient = function(ingredienttype, ...)
        if ingredienttype == CHARACTER_INGREDIENT.HUNGER then
            return true
        end
        return IsCharacterIngredient_old(ingredienttype, ...)
    end

    local function comp_builder(comp)
        local HasCharacterIngredient_old = comp.HasCharacterIngredient
        comp.HasCharacterIngredient = function(self, ingredient, ...)
            if ingredient.type == CHARACTER_INGREDIENT.HUNGER then
                local hunger = self.inst.replica.hunger
                if self.inst.components ~= nil and self.inst.components.hunger ~= nil then
                    --round up hunger to match UI display
                    local current = math.ceil(self.inst.components.hunger.current)
                    return current >= ingredient.amount, current
                elseif hunger ~= nil then
                    --round up hunger to match UI display
                    local current = math.ceil(hunger:GetCurrent())
                    return current >= ingredient.amount, current
                end

                return false, 0
            end
            return HasCharacterIngredient_old(self, ingredient, ...)
        end
    end

    AddComponentPostInit("builder", function(self)
        local RemoveIngredients_old = self.RemoveIngredients
        self.RemoveIngredients = function(self, ingredients, recname, ...)
            local recipe = AllRecipes[recname]
            if recipe and not self.freebuildmode then
                for k, v in pairs(recipe.character_ingredients) do
                    if v.type == CHARACTER_INGREDIENT.HUNGER then
                        self.inst:PushEvent("consumehungercost")
                        self.inst.components.hunger:DoDelta(-v.amount)
                    end
                end
            end
            return RemoveIngredients_old(self, ingredients, recname, ...)
        end
        comp_builder(self)
    end)

    AddClassPostConstruct("components/builder_replica", function(self) comp_builder(self) end)
end
----------------------------------------------------------------
require "behaviours/follow"
require "behaviours/approach"

for _, v in pairs({ "knightbrain", "bishopbrain", "rookbrain" }) do
    AddBrainPostInit(v, function(self)
        local index = nil
        for i, node in ipairs(self.bt.root.children) do
            if node.name == "Follow" then
                local oldfn = node.target
                node.target = function()
                    local leader = self.inst.components.follower ~= nil and self.inst.components.follower.leader
                    if leader and leader:HasTag("kk_chess_leader") then
                        return nil
                    else
                        return FunctionOrValue(oldfn, self.inst)
                    end
                end
                index = i
                break
            end
        end
        if index ~= nil then
            table.insert(self.bt.root.children, index, WhileNode(function()
                    local leader = self.inst.components.follower ~= nil and self.inst.components.follower.leader
                    return leader and leader:HasTag("kk_chess_leader")
                end, "Follow Chess Leader",
                Follow(self.inst, function() return self.inst.components.follower.leader end, 2, 7, 20, v ~= "rookbrain")))
            table.insert(self.bt.root.children, index + 1, WhileNode(function()
                    local leader = self.inst.components.follower ~= nil and self.inst.components.follower.leader
                    return leader and leader:HasTag("kk_chess_leader")
                end, "Go To Point",
                Approach(self.inst, function() return self.inst.components.follower.leader.kk_cane_pos end, 3, false)))
        end
    end)
end

----------------------------------------------------------------
local params = {}
local containers = require("containers")
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)

        return
    end

    return old_widgetsetup(container, prefab, data, ...)
end

params.kk_wctophat =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x2",
        animbuild = "ui_chest_3x2",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.kk_wctophat.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

params.kk_wctophat_up =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.kk_wctophat_up.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
