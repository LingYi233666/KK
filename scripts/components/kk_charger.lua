local Charger= Class(function(self, inst)
    self.inst = inst
    self.canchargefn = nil
    self.onchargefn = nil

    inst:AddTag("kk_charger")
end)

function Charger:Charge(user, target)
    if self.onchargefn then
        self.onchargefn(self.inst, user, target)
    end
    if not self.dontconsume then
        if self.inst.components.finiteuses then
            self.inst.components.finiteuses:Use(self.uses or 1)
        elseif self.inst.components.stackable then
            self.inst.components.stackable:Get():Remove()
        else 
            self.inst:Remove()
        end
    end
    return true
end

function Charger:CanCharge(user, target)
    if self.canchargefn then
        return self.canchargefn(self.inst, user, target)
    end
    return true
end

return Charger