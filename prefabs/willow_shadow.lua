-- AUTOGENERATED CODE BY export_accountitems.lua

local assets =
{
	Asset("ANIM", "anim/ghost_willow_build.zip"),
	Asset("DYNAMIC_ANIM", "anim/dynamic/willow_shadow.zip"),
}

return CreatePrefabSkin("willow_shadow",
{
	base_prefab = "willow",
	type = "base",
	assets = assets,
	build_name = "willow_shadow",
	rarity = "Elegant",
	skins = { ghost_skin = "ghost_willow_build", normal_skin = "willow_shadow", },
})