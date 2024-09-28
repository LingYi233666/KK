local assets =
{
    Asset("ANIM", "anim/kk_materials.zip"),
}

local function makecoating(name, commonfn, masterfn)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("kk_coating")
        inst:AddTag("kk_coating"..name)
        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst.OnBuiltFn = function(inst, builder)
            local fx = nil
            local delay = 0
            if builder:HasTag("k_k") then
                local workspace = FindClosestEntity(builder, 5, true, {"kk_workspace"}, {"burnt"}, nil)
                if workspace and workspace.OnCoating ~= nil then
                    workspace.OnCoating(workspace, builder, inst)
                    delay = 30*FRAMES
                else
                    fx = "spawn_fx_medium"
                end
                builder:PushEvent("kk_statechanged", {onload=false, norefreshstate=true, newskins=true, kk_skins=name, fx=fx, delay=delay})
                if builder.components.kk_light ~= nil then
                    builder.components.kk_light:UpdateAnim()
                end
            end
            inst:Remove()
        end
        inst:DoTaskInTime(1,function() inst:Remove() end)

        return inst
    end

    return Prefab("kk_coating_"..name, fn, assets)
end

local coating = {}
local coating_data = {
    nightmare = {},
    humanlike = {},
}

for k,v in pairs(coating_data) do
    table.insert(coating, makecoating(k, v.commonfn, v.masterfn))
end

return unpack(coating)