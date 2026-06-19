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

is_equippable_enum :: proc(item_name: Item_Name) -> bool {
	#partial switch data in items[item_name].data {
	case Equippable:
		return true
	}
	return false
}

is_equippable_int :: proc(item_idx: int) -> bool {
	return is_equippable_enum(Item_Name(item_idx))
}

is_equippable :: proc {
	is_equippable_enum,
	is_equippable_int,
}
