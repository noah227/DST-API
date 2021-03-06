-- AUTOGENERATED CODE BY export_accountitems.lua

local assets =
{
	Asset("ANIM", "anim/ghost_waxwell_build.zip"),
	Asset("ANIM", "anim/waxwell.zip"),
}

return CreatePrefabSkin("waxwell_none",
{
	base_prefab = "waxwell",
	type = "base",
	assets = assets,
	build_name = "waxwell",
	rarity = "Common",
	skins = { ghost_skin = "ghost_waxwell_build", normal_skin = "waxwell", },
})
