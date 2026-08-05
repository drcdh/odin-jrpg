package game

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"

Bool_Datum :: enum {
	Introduction,
	Met_Dude,
	Met_Woman,
}

Int_Datum :: enum {
	Kills_Mouse_Sized_Rat,
	Kills_Rat_Sized_Mouse,
}

Money :: u32
MONEY_MAX :: 999999 //u32(0xffffffff)

Game_Data :: struct {
	bool_data:        [len(Bool_Datum)]bool,
	int_data:         [len(Int_Datum)]i32,
	party_membership: [NUM_PC]bool,
	protagonist_name: string,
	boat_coord:       Tile_Coord,
	inventory:        [NUM_ITEMS]u8,
	money:            Money,
}

Character_Save_Data :: struct {
	equipment:   Equipment,
	exp_to_next: Maybe(int),
	hitpoints:   int,
	level:       int,
	status:      Status,
}

Save_Data :: struct {
	character_data: [NUM_PC]Character_Save_Data,
	game_data:      Game_Data,
	save_point:     Save_Point,
}

game_data: Game_Data

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
	game_data.inventory[Item_Name.Speed_Ring] = 2
	game_data.inventory[Item_Name.Beginners_Wand] = 1
	game_data.inventory[Item_Name.Rat_Smashing_Bat] = 1
	game_data.inventory[Item_Name.Postcard] = 4
	game_data.inventory[Item_Name.Small_Smoke_Bomb] = 5
	game_data.money = Money(MONEY_MAX / 8)
	set_inventory_order()
	character_unequip_all(&PROTAGONIST, to_inventory = false)
	character_unequip_all(&ASSASSIN, to_inventory = false)
	character_unequip_all(&MUSICIAN, to_inventory = false)
	character_unequip_all(&KILLER, to_inventory = false)
	character_unequip_all(&MOURNER, to_inventory = false)
	character_unequip_all(&ZEALOT, to_inventory = false)
	character_set_equipped_item(&PROTAGONIST, .Mainhand, .Sword, false, false)
	character_set_equipped_item(&PROTAGONIST, .Accessory, .Speed_Ring)
	set_level(&PROTAGONIST, 1)
	set_level(&ASSASSIN, 1)
	set_level(&MUSICIAN, 1)
	set_level(&KILLER, 1)
	set_level(&MOURNER, 1)
	set_level(&ZEALOT, 1)
	set_all_skills()
	heal_party()
}

encode_character_data :: proc() -> (d: [NUM_PC]Character_Save_Data) {
	for pc_idx in 0 ..< NUM_PC {
		pc := get_pc(pc_idx)
		d[pc_idx].equipment = pc.equipment
		d[pc_idx].exp_to_next = pc.exp_to_next
		d[pc_idx].hitpoints = pc.hitpoints
		d[pc_idx].level = pc.level
		d[pc_idx].status = pc.status
	}
	return
}

generate_save_game_data :: proc(save_point: Save_Point) -> Save_Data {
	return Save_Data{encode_character_data(), game_data, save_point}
}

save_game :: proc(save_point: Save_Point) {
	info := generate_save_game_data(save_point)

	json_data, err := json.marshal(info, {pretty = true, use_enum_names = true})
	if err != nil {
		fmt.eprintfln("Unable to marshal JSON: %v", err)
		quitting = true
	}

	path := "saves/save_game.json"

	werr := os.write_entire_file(path, json_data)
	if werr != nil {
		fmt.eprintfln("Unable to write save game file: %v", werr)
		quitting = true
	}

	fmt.printfln("Saved game to %s", path)
}

read_saved_game_data :: proc(filename: string) -> (save_data: Save_Data) {
	filepath := strings.concatenate({"./saves/", filename}, context.temp_allocator)
	json_data, err := os.read_entire_file(filepath, context.temp_allocator)
	if err != nil {
		fmt.eprintfln("Failed to read the file '%s': %v", filepath, err)
		os.exit(1)
	}
	// defer delete(json_data)

	unmarshal_err := json.unmarshal(json_data, &save_data)
	if unmarshal_err != nil {
		fmt.eprintfln("Failed to unmarshal save game data: %v", unmarshal_err)
		os.exit(1)
	}

	return
}

load_saved_game :: proc(save_data: Save_Data) {
	game_data = save_data.game_data
	set_inventory_order()
	character_unequip_all(&PROTAGONIST, to_inventory = false)
	character_unequip_all(&ASSASSIN, to_inventory = false)
	character_unequip_all(&MUSICIAN, to_inventory = false)
	character_unequip_all(&KILLER, to_inventory = false)
	character_unequip_all(&MOURNER, to_inventory = false)
	character_unequip_all(&ZEALOT, to_inventory = false)

	for csd, pc_idx in save_data.character_data {
		pc := get_pc(pc_idx)
		set_level(pc, csd.level)
		pc.exp_to_next = csd.exp_to_next
		for slot in Equipment_Slot {
			character_set_equipped_item(pc, slot, csd.equipment[slot], false, false)
		}
		pc.hitpoints = csd.hitpoints
		pc.status = csd.status
	}
	set_all_skills()
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

inc_money :: proc(v: Money) {
	prev := game_data.money
	game_data.money += v
	if game_data.money < prev {
		// overflowed
		game_data.money = MONEY_MAX
	}
	if game_data.money > MONEY_MAX {
		game_data.money = MONEY_MAX
	}
	fmt.printfln("Money increased by %d from %d to %d", v, prev, game_data.money)
}

dec_money :: proc(v: Money) {
	prev := game_data.money
	if v >= game_data.money {
		game_data.money = 0
	} else {
		game_data.money -= v
	}
	fmt.printfln("Money decreased by %d from %d to %d", v, prev, game_data.money)
}

have_money_Money :: proc(v: Money) -> bool {
	return game_data.money >= v
}

have_money_Price :: proc(v: Price) -> bool {
	switch v in v {
	case Money:
		return have_money_Money(Money(v))
	}
	return false
}

have_money :: proc {
	have_money_Money,
	have_money_Price,
}

get_sell_price :: proc(v: Money) -> Money {
	return Money(0.25 * f32(v))
}
