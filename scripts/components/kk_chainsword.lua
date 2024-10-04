local KKChainSword = Class(function(self, inst)
    self.inst = inst
end)

function KKChainSword:DoAttack(owner, target)
    -- targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos
    owner.components.combat:DoAttack(target, self.inst)
end

return KKChainSword
