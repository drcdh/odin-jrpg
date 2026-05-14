package game

import hm "core:container/handle_map"

DUDE_ID: Id = 1
BUTTON_1_ID: Id = 40

DUDE_SCRIPT_0 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Set_Entity_Busy{id = DUDE_ID, busy = true},
	Append_Text{text = "Oh, hey! What's up, $player?"},
	Clear_Text{},
	Append_Text{text = "Anyway, I'm going over there now."},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Talk_Script{id = DUDE_ID, script = DUDE_SCRIPT_1[:]},
	Set_Entity_State{id = DUDE_ID, state = Pacing{route = LEVEL_0_DUDE_ROUTE_1}},
	Set_Bool{k = .Met_Dude, v = true},
	Set_Entity_Busy{id = DUDE_ID, busy = false},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

DUDE_SCRIPT_1 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Append_Text{text = "Keep on keepin' on.", pause = .5, hurry = true},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

BUTTON_1_SCRIPT := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Set_Entity_Texture{id = BUTTON_1_ID, texture = .Button_Pressed},
	Append_Text{text = "*Beep*"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	Pause_Runner{1},
	Set_Entity_Texture{id = BUTTON_1_ID, texture = .Button},
	End{},
}

BUTTON_2_SCRIPT := [?]Event {
	Clear_Text{},
	Append_Text{text = "*Boop*", pause = .5, hurry = true},
	Close_Dialogue{},
	Clear_Text{},
	End{},
}

MONSTER_IN_A_BOX := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Append_Text{text = "Monster in a box!"},
	Close_Dialogue{},
	Clear_Text{},
	Start_Encounter{encounter = 0},
	Append_Text{text = "Didja win?"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

welcome := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Up{},
	Append_Text{text = "You're new in town|\nPress Z to start!"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Bool{k = .Introduction, v = true},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

WARP_TO_1 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_1},
	Curtain_Up{},
	End{},
}

start_level_0 :: proc() {
	add_pc_entity(LEVEL_0_PLAYER_SPAWN, .Down)

	if get_game_data(Bool_Datum.Met_Dude) {
		_ = hm.add(
			&entities,
			Entity {
				id = DUDE_ID,
				face = .Down,
				tile = LEVEL_0_DUDE_SPAWN_MET,
				speed = 2,
				n = "Dude",
				talk = DUDE_SCRIPT_1[:],
				state = Pacing{route = LEVEL_0_DUDE_ROUTE_1, pause = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	} else {
		_ = hm.add(
			&entities,
			Entity {
				id = DUDE_ID,
				face = .Down,
				tile = LEVEL_0_DUDE_SPAWN_NOT_MET,
				speed = 2,
				n = "Dude",
				talk = DUDE_SCRIPT_0[:],
				state = Pacing{route = LEVEL_0_DUDE_ROUTE_0, pause = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}

	_ = hm.add(
		&entities,
		Entity {
			id = 3,
			ghost = true,
			tile = LEVEL_0_WARP_SPAWN,
			n = "warp",
			trap = WARP_TO_1[:],
			v = animation_create(.Warp),
		},
	)

	// _ = hm.add(
	// 	&entities,
	// 	Entity {
	// 		id = BUTTON_1_ID,
	// 		tile = PLAYER_SPAWN + {1, 1},
	// 		n = "Button 1",
	// 		talk = BUTTON_1_SCRIPT[:],
	// 		v = Texture_Name.Button,
	// 	},
	// )
	//
	// _ = hm.add(
	// 	&entities,
	// 	Entity{id = 50, tile = PLAYER_SPAWN + {2, 1}, n = "Button 2", talk = BUTTON_2_SCRIPT[:], v = Texture_Name.Button},
	// )

	_ = hm.add(
		&entities,
		Entity {
			id = 100,
			tile = LEVEL_0_CHEST_MONSTER,
			n = "Monster in a box",
			talk = MONSTER_IN_A_BOX[:],
			v = Texture_Name.Box,
		},
	)

	if !get_game_data(Bool_Datum.Introduction) {
		start_script(welcome[:])
	}
}
