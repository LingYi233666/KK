local KKWorldGenBase = Class(function(self, inst)
    self.inst = inst
    self.name = "kk_worldgen_base"

    self.generated = false

    inst:DoTaskInTime(1, function()
        self:TryGenerate()
    end)
end)

function KKWorldGenBase:CanGenerate()
    return self.generated == false
end

function KKWorldGenBase:TryGenerate()
    if not self:CanGenerate() then
        return
    end

    local success, reason = self:Generate()
    if not success then
        print(self.name .. " generate failed, reason: " .. tostring(reason))
        return
    end

    self.generated = true
end

function KKWorldGenBase:Generate()
    return false, "You forget to set Generate() function, go do it !"
end

function KKWorldGenBase:OnSave()
    local data = {}
    data.generated = self.generated
    return data
end

function KKWorldGenBase:OnLoad(data)
    if data ~= nil then
        if data.generated ~= nil then
            self.generated = data.generated
        end
    end
end

return KKWorldGenBase
