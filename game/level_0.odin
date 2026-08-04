package game

LEVEL_0_OVERLAY :: true

BOX_0_ID :: 200
BOX_1_ID :: 201
BOX_2_ID :: 202
BUTTON_1_ID :: 41
BUTTON_2_ID :: 42
DUDE_ID :: 1
JUKEBOX_ID :: 100
SIGN_ID :: 101
WARP_0_1_ID :: 300

dude_script_0 :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Set_Entity_Busy{id = DUDE_ID, busy = true},
			Set_Entity_Face_Party{id = DUDE_ID},
			Append_Text{"Oh, hey! What's up, $player?"},
			Clear_Text{},
			Append_Text{"Coffee or tea?"},
			Append_Choice{"Coffee"},
			Append_Choice{"Tea"},
			Get_Choice{},
			Clear_Text{},
			Skip_If_Choice{12, 1}, // goto: Tea
			// Coffee
			Append_Text{"Ooh, sludgy!"},
			Clear_Text{},
			Append_Text{"With or without cream?"},
			Append_Choice{"With!"},
			Append_Choice{"Without."},
			Get_Choice{},
			Clear_Text{},
			Skip_If_Choice{2, 1}, // goto: no cream
			// yes cream
			Append_Text{"So that's a coffee with cream? Cool, I dunno where a coffee shop is, though. Sorry!"},
			Skip{1},
			// no cream
			Append_Text{"So that's a black coffee? Cool, I dunno where a coffee shop is, though. Sorry!"},
			Skip{6},
			// Tea
			Append_Text{"Ooh, grassy!"},
			Clear_Text{},
			Append_Text{"Y'know what? I actually have an extra cup of hot tea right here. How about that?"},
			Clear_Text{},
			Add_Item{item = .Tea, number = 1},
			Append_Text{"Got item: Tea"},
			Clear_Text{},
			Append_Text{"Anyway, I'm going over there now."},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Talk_Script{id = DUDE_ID, script = dude_script_1},
			Set_Entity_State{id = DUDE_ID, state = Pacing{route = LEVEL_0_DUDE_ROUTE_1}},
			Set_Bool{k = .Met_Dude, v = true},
			Set_Entity_Busy{id = DUDE_ID, busy = false},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

dude_script_1 :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text_Ex{text = "Keep on keepin' on.", pause = .5, hurry = true},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

button_1_script :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Set_Entity_Texture{id = BUTTON_1_ID, texture = .Button_Pressed},
			Append_Text{"*Beep*"},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			Pause_Runner{1},
			Set_Entity_Texture{id = BUTTON_1_ID, texture = .Button},
			End{},
		},
	)
}

button_2_script :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Texture{id = BUTTON_2_ID, texture = .Button_Pressed},
			Append_Text_Ex{text = "*Boop*", pause = .5, hurry = true},
			Close_Dialogue{},
			Clear_Text{},
			Pause_Runner{1},
			Set_Entity_Texture{id = BUTTON_2_ID, texture = .Button},
			End{},
		},
	)
}

monster_in_a_box :: proc(encounter: int) {

	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text{"Monster in a box!"},
			Close_Dialogue{},
			Clear_Text{},
			Curtain_Down{.Battle},
			Start_Encounter{encounter = encounter, paused = true},
			// Curtain_Up{.Battle},
			// Append_Text{"Oh noes!"},
			// Close_Dialogue{},
			// Clear_Text{},
			// Battle_Unpause{},
			// Wait_Encounter{},
			Curtain_Up{.Battle},
			Append_Text{"Didja win?"},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

monster_in_a_box_1 :: proc() {
	monster_in_a_box(1)
}

monster_in_a_box_2 :: proc() {
	monster_in_a_box(2)
}

welcome :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Curtain_Up{},
			Append_Text{"You're new in town|\nPress Z to start!"},
			Close_Dialogue{},
			Clear_Text{},
			Set_Bool{k = .Introduction, v = true},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

warp_to_1 :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Play_Sound{sound = .Warp},
			Curtain_Down{},
			Start_Level{level = .LEVEL_1},
			Curtain_Up{},
			End{},
		},
	)
}

lorem_ipsum :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text_Ex {
				// text = "Line 1.\nLine 2..\nLine 3...\nLine 4....\nLine 5.....",
				text  = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
				lines = 6,
			},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

jukebox :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text {
				"This may look like an ol'-timey jukebox, but it's actually a subtemporal meso-reconstructive bio-phasmatron! Use it, and almost instantaneously you'll feel like you've had a good long rest.",
			},
			Append_Choice{"Use it!"},
			Append_Choice{"Nah, I'm good."},
			Get_Choice{},
			Clear_Text{},
			Skip_If_Choice{20, 1},
			Append_Text{"Sure. You still gotta put money in it, though. It's similar to a jukebox in that way."},
			Append_Choice{"Ugh, fine. $3"},
			Append_Choice{"What? No way."},
			Get_Choice{},
			Clear_Text{},
			Skip_If_Choice{14, 1},
			Skip_If_Have_Money{2, 3},
			Append_Text{"You can't afford it!"},
			Skip{11},
			Lose_Money{3},
			Curtain_Down{},
			Heal_Party{},
			Pause_Runner{.5},
			Play_Sound{sound = .Warp},
			Pause_Runner{.5},
			Curtain_Up{},
			Append_Text{"You feel great!"},
			Clear_Text{},
			Pause_Runner{.5},
			Append_Text{"|but you're still hungry."},
			Clear_Text{},
			Close_Dialogue{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

level_0_save :: proc() {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text{"Ooh, it's a save point! Save your game?"},
			Append_Choice{"Yeah!"},
			Append_Choice{"Nope."},
			Get_Choice{},
			Clear_Text{},
			Skip_If_Choice{1, 1},
			Save_Game{.Level_0},
			Close_Dialogue{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

start_level_0 :: proc() {
	add_pc_entity(LEVEL_0_PLAYER_SPAWN, .Down)

	if get_game_data(Bool_Datum.Met_Dude) {
		add_world_entity(
			Entity {
				id = DUDE_ID,
				face = .Down,
				tile = LEVEL_0_DUDE_SPAWN_MET,
				speed = 2,
				n = "Dude",
				talk = dude_script_1,
				state = Pacing{route = LEVEL_0_DUDE_ROUTE_1, pause = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	} else {
		add_world_entity(
			Entity {
				id = DUDE_ID,
				face = .Down,
				tile = LEVEL_0_DUDE_SPAWN_NOT_MET,
				speed = 2,
				n = "Dude",
				talk = dude_script_0,
				state = Pacing{route = LEVEL_0_DUDE_ROUTE_0, pause = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}

	add_world_entity(
		Entity {
			id = WARP_0_1_ID,
			ghost = true,
			tile = LEVEL_0_WARP_SPAWN,
			n = "warp",
			trap = warp_to_1,
			v = animation_create(.Warp),
		},
	)

	add_world_entity(
		Entity {
			id = BUTTON_1_ID,
			tile = LEVEL_0_PLAYER_SPAWN + {1, 1},
			n = "Button 1",
			talk = button_1_script,
			v = Texture_Name.Button,
		},
	)

	add_world_entity(
		Entity {
			id = BUTTON_2_ID,
			tile = LEVEL_0_PLAYER_SPAWN + {2, 1},
			n = "Button 2",
			talk = button_2_script,
			v = Texture_Name.Button,
		},
	)

	add_world_entity(Entity {
		id = BOX_0_ID,
		tile = LEVEL_0_CHEST_MONSTER,
		n = "Monster in a box",
		talk = proc() {monster_in_a_box(0)},
		v = Texture_Name.Box,
	})

	add_world_entity(
		Entity {
			id = BOX_1_ID,
			tile = LEVEL_0_CHEST_MONSTER + {0, 1},
			n = "Monster in a box",
			talk = monster_in_a_box_1,
			v = Texture_Name.Box,
		},
	)

	add_world_entity(
		Entity {
			id = BOX_2_ID,
			tile = LEVEL_0_CHEST_MONSTER + {0, 2},
			n = "Monster in a box",
			talk = monster_in_a_box_2,
			v = Texture_Name.Box,
		},
	)

	add_world_entity(
		Entity{id = SIGN_ID, tile = LEVEL_0_SIGN, n = "Lorem Ipsum sign", talk = lorem_ipsum, v = Texture_Name.Sign},
	)

	add_world_entity(
		Entity{id = JUKEBOX_ID, tile = LEVEL_0_JUKEBOX, n = "Jukebox", talk = jukebox, v = Texture_Name.Jukebox},
	)

	add_world_entity(
		Entity {
			id = 800,
			tile = LEVEL_0_SAVE,
			ghost = true,
			n = "Level_0_Save",
			v = animation_create(.Save_Point_Active),
			trap = level_0_save,
		},
	)

	play_music(&music_state, .Town)

	if !get_game_data(Bool_Datum.Introduction) {
		welcome()
	}
}
