package game

Item :: struct {
	name: string,
	data: Item_Variant,
}

Item_Variant :: union {
	Consumable,
	Equippable,
}

Consumable :: Skill_Name

Equippable :: struct {
	stats_add: Stats,
	stats_mul: Stats,
	slot:      Equipment_Slot,
}

NUM_ITEMS :: len(Item_Name) - 1
