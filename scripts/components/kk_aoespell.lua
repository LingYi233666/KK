
local  Aoespell = Class(function(self, inst)
	self.inst = inst
	self.spellya = true
end)


function Aoespell:CanCast(doer, pos)
	return self.spellya 
end


function Aoespell:SFL_SetSpellFn(fn)
	self.spellya = fn
end

function Aoespell:CastSpell(doer, pos)
    if self.spellya ~= nil then
        self.spellya(self.inst,doer, pos)
	end
	return true
end

return Aoespell