package game

inventory_order: [dynamic]Item_Name
equippables_order: [dynamic]Item_Name

set_inventory_order :: proc() {
	clear(&inventory_order)
	for n, i in game_data.inventory {
		if n > 0 {
			append(&inventory_order, Item_Name(i))
		}
	}
	clear(&equippables_order)
	for n, i in game_data.inventory {
		if n > 0 && is_equippable(i) {
			append(&equippables_order, Item_Name(i))
		}
	}
	append(&equippables_order, Item_Name.None)
}
