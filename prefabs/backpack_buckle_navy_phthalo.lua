-- AUTOGENERATED CODE BY export_accountitems.lua

local assets =
{
	Asset("DYNAMIC_ANIM", "anim/dynamic/swap_backpack_buckle_navy_phthalo.zip"),
	Asset("DYNAMIC_ANIM", "anim/dynamic/swap_backpack_mushy.zip"),
}

return CreatePrefabSkin("backpack_buckle_navy_phthalo",
{
	base_prefab = "backpack",
	type = "item",
	assets = assets,
	build_name = "swap_backpack_buckle_navy_phthalo",
	rarity = "Spiffy",
	init_fn = function(inst) backpack_init_fn(inst, "swap_backpack_buckle_navy_phthalo") end,
})
