local function OnEquip(inst, data)
    local self = inst.components.kk_light
    if not self then
        return
    end
    self:UpdateAnim()
end

local function ondeath(inst, data)
    if inst.components.kk_light ~= nil then
        inst.components.kk_light:SwitchLight(false, true)
    end
end

local function OnStateChanged(inst, data)
    local lightoff = data and data.lightoff
    if lightoff then
        ondeath(inst)
    end
end

local Light= Class(function(self, inst)
    self.inst = inst
    inst:AddTag("kk_light")

    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("death", ondeath)
    inst:ListenForEvent("kk_statechanged", OnStateChanged)
end)

function Light:OnSave()
    local data = {}
    data.lighton = self.inst:HasTag("kk_light_on")

    return data
end

function Light:OnLoad(data)
    if data.lighton then
        self:SwitchLight(true)
    end
end

function Light:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("equip", OnEquip)
    self.inst:RemoveEventCallback("death", ondeath)
end

function Light:UpdateAnim()
    if self._light then
        if self.inst.kk_skins == "humanlike" then
            self.inst.AnimState:OverrideSymbol("hair", "kk_light", "hair_humanlike")
            self.inst.AnimState:ClearOverrideSymbol("headbase")
            self.inst.AnimState:ClearOverrideSymbol("headbase_hat")
        else
            self.inst.AnimState:OverrideSymbol("headbase", "kk_light", "headbase_normal")
            self.inst.AnimState:OverrideSymbol("headbase_hat", "kk_light", "headbase_hat_normal")
        end
    else
        self.inst.AnimState:ClearOverrideSymbol("hair")
        self.inst.AnimState:ClearOverrideSymbol("headbase")
        self.inst.AnimState:ClearOverrideSymbol("headbase_hat")
    end
end

function Light:SwitchLight(light, forceoff)
    local _light = light ~= nil and light or not self.inst:HasTag("kk_light_on")
    if forceoff then
        _light = false
    end
    self._light = _light
    if _light then
        if not self.inst._kk_light then
            --local currentfacing = self.inst.AnimState:GetCurrentFacing()
            --local offset = currentfacing == FACING_UP and 55 or -58
            self.inst._kk_light = SpawnPrefab("kk_light")
            --self.inst._kk_light.AnimState:SetScale(.5, .5)
            --[[self.inst._kk_light.entity:AddFollower()
            self.inst._kk_light.Follower:FollowSymbol(self.inst.GUID, "headbase", offset, -150, 0)
            local lastfacing = nil
            self.inst._kk_light:DoPeriodicTask(FRAMES, function()
                if not self.inst._kk_light then return end
                local currentfacing = self.inst.AnimState:GetCurrentFacing()
                if currentfacing ~= lastfacing then
                    local offset = currentfacing == FACING_UP and 55 or -58
                    self.inst._kk_light.Follower:FollowSymbol(self.inst.GUID, "headbase", offset, -150, 0)
                    lastfacing = currentfacing
                end
                
            end)]]
            self.inst._kk_light.entity:SetParent(self.inst.entity)
            --self.inst._kk_light.Transform:SetPosition(1,1.8,0)
        end
        self.inst._kk_light.Light:Enable(true)
        if not self.inst:HasTag("kk_light_on") then
            self.inst:AddTag("kk_light_on")
        end
        if self.inst.components.hunger ~= nil then
            self.inst.components.hunger.burnratemodifiers:SetModifier(self.inst, 1.2)
        end
    else
        if self.inst._kk_light then
            self.inst._kk_light:Remove()
            self.inst._kk_light = nil
        end
        if self.inst:HasTag("kk_light_on") then
            self.inst:RemoveTag("kk_light_on")
        end
        if self.inst.components.hunger ~= nil then
            self.inst.components.hunger.burnratemodifiers:RemoveModifier(self.inst)
        end
    end

    self.inst:DoTaskInTime(.1,function() self:UpdateAnim() end)

    return true
end

return Light