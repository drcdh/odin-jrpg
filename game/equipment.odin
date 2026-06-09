package game

import "core:fmt"

Equipment_Slot :: enum {
	Mainhand,
	Sidehand,
	Accessory,
}

NUM_EQUIPMENT_SLOTS :: len(Equipment_Slot)

Equipment :: [len(Equipment_Slot)]Item_Name

equipped_item :: proc(equipment: Equipment, slot: Equipment_Slot) -> Item_Name {
	return equipment[slot]
}

set_equipped_item :: proc(equipment: ^Equipment, slot: Equipment_Slot, item: Item_Name, from_inventory := true, to_inventory := true) {
	prev := equipment[slot]
	equipment[slot] = item
	if item != .None && from_inventory {
		game_data.inventory[item] -= 1
	}
	if prev != .None && to_inventory {
		game_data.inventory[prev] += 1
	}
}

unequip_all :: proc(equipment: ^Equipment, to_inventory := true) {
	for s in 0 ..< NUM_EQUIPMENT_SLOTS {
		set_equipped_item(equipment, Equipment_Slot(s), .None, false, to_inventory)
	}
}

equipment_string :: proc(equipment: Equipment, slot: Equipment_Slot) -> string {
	item := equipped_item(equipment, slot)
	item_name := items[item].name if item != .None else ""
	switch slot {
	case .Mainhand:
		return fmt.aprintf("Mainhand:  %s", item_name)
	case .Sidehand:
		return fmt.aprintf("Sidehand:  %s", item_name)
	case .Accessory:
		return fmt.aprintf("Accessory: %s", item_name)
	}
	return "bad_equipment_slot"
}
