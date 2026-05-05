package game

Bool_Datum :: enum {
	Introduction,
	Met_Dude,
}

Int_Datum :: enum {
	Kills_Mouse_Sized_Rat,
	Kills_Rat_Sized_Mouse,
}

game_data : struct {
	bool_data: [len(Bool_Datum)]bool,
	int_data: [len(Int_Datum)]i32,
	protagonist_name: string,
}

init_new_game :: proc() {
	game_data.protagonist_name = "Hiro"
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

set_game_data :: proc{
	set_game_data_bool,
	set_game_data_int,
}
