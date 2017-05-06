-- AUTOGENERATED CODE BY export_accountitems.lua

local assets =
{
	Asset("ANIM", "anim/ghost_wx78_build.zip"),
	Asset("DYNAMIC_ANIM", "anim/dynamic/wx78_shadow.zip"),
}

return CreatePrefabSkin("wx78_shadow",
{
	base_prefab = "wx78",
	type = "base",
	assets = assets,
	build_name = "wx78_shadow",
	rarity = "Elegant",
	skins = { ghost_skin = "ghost_wx78_build", normal_skin = "wx78_shadow", },
	has_alternate_for_body = { "wx78_shadow", },
})
