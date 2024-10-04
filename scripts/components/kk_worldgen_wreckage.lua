local KKWorldGenBase = require("components/kk_worldgen_base")


local KKWorldGenWreckage = Class(KKWorldGenBase, function(self, inst)
    KKWorldGenBase._ctor(self, inst)

    self.name = "kk_worldgen_wreckage"

    self.percent_replace = 0.333
end)

function KKWorldGenWreckage:Generate()
    local ents_to_be_replaced = {}
    for _, v in pairs(Ents) do
        if v.prefab == "skeleton" then
            table.insert(ents_to_be_replaced, v)
        end
    end

    local num_skeleton = #ents_to_be_replaced
    local num_to_replace = math.max(1, math.floor(self.percent_replace * num_skeleton))
    local replace_cnt = 0

    while #ents_to_be_replaced > 0 and replace_cnt < num_to_replace do
        local v = table.remove(ents_to_be_replaced, math.random(1, #ents_to_be_replaced))

        if v and v:IsValid() then
            local new_ent = ReplacePrefab(v, "kk_wreckage")
            replace_cnt = replace_cnt + 1
        end
    end

    print(("%d skeleton found, should transform %d, %d truly transformed"):format(num_skeleton, num_to_replace,
        replace_cnt))

    if replace_cnt > 0 then
        return true
    end

    return false, "No skeleton transformed to kk_wreckage"
end

return KKWorldGenWreckage
