AddRecipe2(
        "kk_workspace",
        {Ingredient("cutstone", 4),Ingredient("transistor", 4),Ingredient("gears", 4),Ingredient("trinket_6", 4),},
        TECH.SCIENCE_TWO,
        {builder_tag="k_k", atlas = KK_IMAGES, image = "kk_workspace.tex", placer="kk_workspace_placer"},
        {"CHARACTER", "PROTOTYPERS", "STRUCTURES"}
    )

AddRecipe2(
        "kk_dormancy",
        {Ingredient("gears", 2),Ingredient("transistor", 1),Ingredient("cutstone", 3),},
        TECH.SCIENCE_TWO,
        {builder_tag="k_k", atlas = KK_IMAGES, placer="kk_dormancy_placer"},
        {"CHARACTER", "STRUCTURES"}
    )

AddRecipe2(
        "kk_dlc",
        {Ingredient("transistor", 2),Ingredient("gears", 2),Ingredient("kk_ironplate", 3, KK_IMAGES),Ingredient("kk_battery", 1, KK_IMAGES),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "WEAPONS", "TOOLS"}
    )

AddRecipe2(
        "kk_holysword",
        {Ingredient("flint", 3),Ingredient("goldnugget", 1),},
        TECH.NONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "WEAPONS", "TOOLS"}
    )

AddRecipe2(
        "kk_repaire",
        {Ingredient("kk_mechanical_leg", 1, KK_IMAGES),Ingredient("kk_mechanical_eye", 1, KK_IMAGES),Ingredient("kk_ironplate", 1, KK_IMAGES),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES, nounlock=true, canbuild=function(recipe, builder) 
            if builder:HasTag("kk_repaired") then
                return false, "KK_ONLYBROKEN"
            end
            return true
        end},
        {"CHARACTER", "TOOLS", "RESTORATION"}
    )

AddRecipe2(
        "kk_derepaire",
        {},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES, image = "kk_derepaire.tex", nounlock=true, canbuild=function(recipe, builder) 
            if not builder:HasTag("kk_repaired") then
                return false, "KK_ONLYREPAIRED"
            end
            return true
        end, min_spacing=1.5},
        {"CHARACTER", "STRUCTURES"}
    )

AddRecipe2(
        "kk_maintain",
        {Ingredient(CHARACTER_INGREDIENT.HUNGER, 50),Ingredient(CHARACTER_INGREDIENT.SANITY, -50),},
        TECH.NONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "TOOLS"}
    )

AddRecipe2(
        "kk_wctophat",
        {Ingredient("tophat", 1),Ingredient("goggleshat", 1),Ingredient("icehat", 1),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "CLOTHING", "SUMMER", "RAIN"}
    )

AddRecipe2(
        "kk_cane",
        {Ingredient("kk_mechanical_eye", 1, KK_IMAGES),Ingredient("lightninggoathorn", 1),Ingredient("cane", 1),Ingredient("transistor", 1),Ingredient("kk_battery", 1, KK_IMAGES),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "WEAPONS", "LIGHT"}
    )

AddRecipe2(
        "kk_battery",
        {Ingredient("transistor", 1),Ingredient("goldnugget", 1),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "TOOLS"}
    )

AddRecipe2(
        "kk_transmitter",
        {Ingredient("gears", 2),Ingredient("mosquitosack", 1),Ingredient("transistor", 1),},
        TECH.NONE,
        {builder_tag="k_k", atlas = KK_IMAGES},
        {"CHARACTER", "TOOLS"}
    )

AddRecipe2(
        "kk_gears_1",
        {Ingredient("kk_ironplate", 1),},
        TECH.NONE,
        {builder_tag="k_k", product="gears", numtogive=2},
        {"CHARACTER", "REFINE"}
    )

AddRecipe2(
        "kk_gears_2",
        {Ingredient("kk_mechanical_leg", 1),},
        TECH.NONE,
        {builder_tag="k_k", product="gears", numtogive=2},
        {"CHARACTER", "REFINE"}
    )

AddRecipe2(
        "kk_gears_3",
        {Ingredient("kk_mechanical_eye", 1),},
        TECH.NONE,
        {builder_tag="k_k", product="gears", numtogive=2},
        {"CHARACTER", "REFINE"}
    )

AddRecipe2(
        "kk_coating_humanlike",
        {Ingredient("pigskin", 3),Ingredient("silk", 6),Ingredient("goatmilk", 1),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES, nounlock=true, canbuild=function(recipe, builder) 
            if not builder:HasTag("kk_repaired") then
                return false, "KK_ONLYREPAIRED"
            end
            return true
        end},
        {"CHARACTER", "CLOTHING"}
    )

AddRecipe2(
        "kk_coating_nightmare",
        {Ingredient("nightmarefuel", 6),Ingredient("livinglog", 3),Ingredient("purplegem", 1),},
        TECH.KK_WORKSPACE_ONE,
        {builder_tag="k_k", atlas = KK_IMAGES, nounlock=true, canbuild=function(recipe, builder) 
            if builder:HasTag("kk_repaired") then
                return false, "KK_ONLYBROKEN"
            end
            return true
        end},
        {"CHARACTER", "CLOTHING"}
    )