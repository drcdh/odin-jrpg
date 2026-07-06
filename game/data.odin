package game

import "core:fmt"

Bool_Datum :: enum {
	Introduction,
	Met_Dude,
	Met_Woman,
}

Int_Datum :: enum {
	Kills_Mouse_Sized_Rat,
	Kills_Rat_Sized_Mouse,
}

game_data: struct {
	bool_data:        [len(Bool_Datum)]bool,
	int_data:         [len(Int_Datum)]i32,
	party_membership: [NUM_PC]bool,
	protagonist_name: string,
	boat_coord:       Tile_Coord,
	inventory:        [NUM_ITEMS]u8,
	money:            i32,
}

init_new_game :: proc() {
	game_data.boat_coord = LEVEL_OVERWORLD_BOAT_SPAWN
	game_data.party_membership = {true, false, false, false, false, false}
	game_data.protagonist_name = "Hiro"
	game_data.inventory[Item_Name.Potion] = 5
	game_data.inventory[Item_Name.Super_Potion] = 4
	game_data.inventory[Item_Name.Antidote] = 2
	game_data.inventory[Item_Name.Poisonous_Mushroom] = 2
	game_data.inventory[Item_Name.Chump_Charm] = 1
	game_data.inventory[Item_Name.Beef_Bracer] = 1
	game_data.inventory[Item_Name.Boost_Donut] = 100
	game_data.money = 123
	set_inventory_order()
	unequip_all(&PROTAGONIST, to_inventory = false)
	unequip_all(&ASSASSIN, to_inventory = false)
	unequip_all(&MUSICIAN, to_inventory = false)
	unequip_all(&KILLER, to_inventory = false)
	unequip_all(&MOURNER, to_inventory = false)
	unequip_all(&ZEALOT, to_inventory = false)
	set_equipped_item(&PROTAGONIST, .Mainhand, .Sword, false, false)
	set_level(&PROTAGONIST, 1)
	set_level(&ASSASSIN, 1)
	set_level(&MUSICIAN, 1)
	set_level(&KILLER, 1)
	set_level(&MOURNER, 1)
	set_level(&ZEALOT, 1)
	set_all_skills()
	heal_party()
}

get_game_data_bool :: proc(d: Bool_Datum) -> bool {
	return game_data.bool_data[d]
}

get_game_data_int :: proc(d: Int_Datum) -> i32 {
	return game_data.int_data[d]
}

get_game_data :: proc {
	get_game_data_bool,
	get_game_data_int,
}

set_game_data_bool :: proc(d: Bool_Datum, v: bool) {
	game_data.bool_data[d] = v
}

set_game_data_int :: proc(d: Int_Datum, v: i32) {
	game_data.int_data[d] = v
}

set_game_data :: proc {
	set_game_data_bool,
	set_game_data_int,
}

item_possession_cstring :: proc(i: Item_Name) -> cstring {
	item := items[i]
	return fmt.caprintf("%s %2d", item.name, game_data.inventory[i], allocator = context.temp_allocator)
}
