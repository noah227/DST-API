-- AUTOGENERATED CODE BY export_accountitems.lua

local assets =
{
	Asset("DYNAMIC_ANIM", "anim/dynamic/hat_hutch_costume.zip"),
}

return CreatePrefabSkin("hat_hutch_costume",
{
	base_prefab = "tophat",
	type = "item",
	assets = assets,
	build_name = "hat_hutch_costume",
	rarity = "Elegant",
	init_fn = function(inst) tophat_init_fn(inst, "hat_hutch_costume") end,
	granted_items = { "researchlab4_hutch_costume", },
})
