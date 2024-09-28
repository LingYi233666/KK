local Dormancy= Class(function(self, inst)
    self.inst = inst
    self.user = nil

    inst:AddTag("kk_dormancycabin")
end)

function Dormancy:Start(doer)
    if doer == nil then
        return false
    end
    if self.user ~= nil then
        return false, "occupied"
    end
    if not (doer:HasTag("k_k") or doer.prefab == "wx78") then
        return false, "unsuited"
    end 

    self.user = doer
    doer.kk_cabin = self.inst

    self.inst.AnimState:PlayAnimation("open")
    self.inst.AnimState:PushAnimation("sleep", true)

    doer:DoTaskInTime(.6, function()
        self.inst.SoundEmitter:PlaySound("WX_rework/scanner/locked_on")

        if doer.sg ~= nil and doer.sg:HasState("kk_cabin") then
            doer.sg:GoToState("kk_cabin")
        end
    end)
    
    return true
end

function Dormancy:Stop(doer)
    doer = doer or self.user
    if doer == nil then
        return false
    end
    self.user = nil
    doer.kk_cabin = nil

    self.inst.SoundEmitter:PlaySound("WX_rework/scanner/locked_on")

    self.inst.AnimState:PlayAnimation("wakeup")
    self.inst.AnimState:PushAnimation("open")
    self.inst.AnimState:PushAnimation("close", true)

    if self.inst.components.playerprox ~= nil then
        self.inst.components.playerprox:ForceUpdate()
    end

    return true
end

function Dormancy:GetUser()
    return self.user
end

return Dormancy