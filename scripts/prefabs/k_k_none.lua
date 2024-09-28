local prefabs = {}

table.insert(prefabs, CreatePrefabSkin("k_k_none",
{
	base_prefab = "k_k",
	build_name_override = "k_k",
	type = "base",
	rarity = "Character",
	rarity_modifier = "CharacterModifier",
	skins = {
		normal_skin = "k_k",
		repaired_skin = "k_k_repaired",
		ghost_skin = "ghost_k_k_build",
	},
	assets = {
		Asset( "ANIM", "anim/k_k.zip" ),
		Asset( "ANIM", "anim/k_k_repaired.zip" ),
		Asset( "ANIM", "anim/k_k_humanlike.zip" ),
		Asset( "ANIM", "anim/k_k_nightmare.zip" ),
		Asset( "ANIM", "anim/ghost_k_k_build.zip" ),
	},
	skin_tags = {"BASE" ,"k_k", "CHARACTER"},
	skip_item_gen = true,
	skip_giftable_gen = true,
}))

table.insert(prefabs, CreatePrefabSkin("k_k_humanlike",
{
	base_prefab = "k_k",
	build_name_override = "k_k_humanlike",
	type = "base",
	rarity = "Elegant",
	rarity_modifier = "CharacterModifier",
	skins = {
		normal_skin = "k_k_humanlike",
		repaired_skin = "k_k_humanlike",
		ghost_skin = "ghost_k_k_build",
	},
	assets = {
		Asset( "ANIM", "anim/k_k_humanlike.zip" ),
		Asset( "ANIM", "anim/ghost_k_k_build.zip" ),
	},
	skin_tags = {"BASE" ,"k_k", "CHARACTER"},
	skip_item_gen = true,
	skip_giftable_gen = true,
	--share_bigportrait_name = "k_k_none",
}))

table.insert(prefabs, CreatePrefabSkin("k_k_nightmare",
{
	base_prefab = "k_k",
	build_name_override = "k_k_nightmare",
	type = "base",
	rarity = "Elegant",
	rarity_modifier = "CharacterModifier",
	skins = {
		normal_skin = "k_k_nightmare",
		repaired_skin = "k_k_nightmare",
		ghost_skin = "ghost_k_k_build",
	},
	assets = {
		Asset( "ANIM", "anim/k_k_nightmare.zip" ),
		Asset( "ANIM", "anim/ghost_k_k_build.zip" ),
	},
	skin_tags = {"BASE" ,"k_k", "CHARACTER"},
	skip_item_gen = true,
	skip_giftable_gen = true,
	share_bigportrait_name = "k_k_none",
}))

return unpack(prefabs)