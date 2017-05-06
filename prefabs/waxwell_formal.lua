-- AUTOGENERATED CODE BY export_accountitems.lua

local assets =
{
	Asset("ANIM", "anim/ghost_waxwell_build.zip"),
	Asset("DYNAMIC_ANIM", "anim/dynamic/waxwell_formal.zip"),
}

return CreatePrefabSkin("waxwell_formal",
{
	base_prefab = "waxwell",
	type = "base",
	assets = assets,
	build_name = "waxwell_formal",
	rarity = "Elegant",
	skins = { ghost_skin = "ghost_waxwell_build", normal_skin = "waxwell_formal", },
	torso_tuck_builds = { "waxwell_formal", },
})