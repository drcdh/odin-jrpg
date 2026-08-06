#+private file
package game

@(private)
LEVEL_0_OVERLAY :: true

dude_script_0 :: proc(dude_id: Id) {
	queue_events(
		[]Event {
			Set_Entity_Busy{PLAYER_ID, true},
			Set_Entity_Busy{dude_id, true},
			Set_Entity_Face_Party{dude_id},
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
			Set_Entity_Talk_Script{dude_id, dude_script_1},
			Set_Entity_State{dude_id, Pacing{route = LEVEL_0_DUDE_ROUTE_1}},
			Set_Bool{k = .Met_Dude, v = true},
			Set_Entity_Busy{dude_id, false},
			Set_Entity_Busy{PLAYER_ID, false},
			End{},
		},
	)
}

dude_script_1 :: proc(id: Id) {
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

@(private)
start_level_0 :: proc() {
	add_pc_entity(LEVEL_0_PLAYER_SPAWN, .Down)

	if get_game_data(Bool_Datum.Met_Dude) {
		add_world_entity(
			Entity {
				id = new_id(),
				face = .Down,
				tile = LEVEL_0_DUDE_SPAWN_MET,
				speed = 2,
				n = "Dude",
				talk = dude_script_1,
				state = Pacing{route = LEVEL_0_DUDE_ROUTE_1, pause = 1},
				v = create_sprite_state(.Dude_World, .Down),
				z = Z_MAX,
			},
		)
	} else {
		add_world_entity(
			Entity {
				id = new_id(),
				face = .Down,
				tile = LEVEL_0_DUDE_SPAWN_NOT_MET,
				speed = 2,
				n = "Dude",
				talk = dude_script_0,
				state = Pacing{route = LEVEL_0_DUDE_ROUTE_0, pause = 1},
				v = create_sprite_state(.Dude_World, .Down),
				z = Z_MAX,
			},
		)
	}

	add_world_entity(Entity {
		id = new_id(),
		ghost = true,
		tile = LEVEL_0_WARP_SPAWN,
		n = "warp",
		trap = proc(_: Id) {warp_to_level(.Level_1)},
		v = create_sprite_state(.Warp),
	})

	add_world_entity(Entity {
		id = new_id(),
		ghost = true,
		tile = LEVEL_0_WARP_CAVE,
		n = "warp",
		trap = proc(_: Id) {warp_to_level(.Level_Cave)},
		v = create_sprite_state(.Warp),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_PLAYER_SPAWN + {1, 1},
		n = "Button 1",
		talk = proc(id: Id) {
			queue_events(
				[]Event {
					Set_Entity_Busy{PLAYER_ID, true},
					Set_Entity_Tag{id, .Down},
					Append_Text{"*Beep*"},
					Close_Dialogue{},
					Clear_Text{},
					Set_Entity_Busy{PLAYER_ID, false},
					Pause_Runner{1},
					Set_Entity_Tag{id, .Up},
					End{},
				},
			)
		},
		v = create_sprite_state(.Button),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_PLAYER_SPAWN + {2, 1},
		n = "Button 2",
		talk = proc(id: Id) {
			queue_events(
				[]Event {
					Set_Entity_Tag{id, .Down},
					Append_Text_Ex{text = "*Boop*", pause = .5, hurry = true},
					Close_Dialogue{},
					Clear_Text{},
					Pause_Runner{1},
					Set_Entity_Tag{id, .Up},
					End{},
				},
			)
		},
		v = create_sprite_state(.Button),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_CHEST_MONSTER,
		n = "Monster in a box",
		talk = proc(id: Id) {monster_in_a_box(id, 0)},
		v = create_sprite_state(.Box),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_CHEST_MONSTER + {0, 1},
		n = "Monster in a box",
		talk = proc(id: Id) {monster_in_a_box(id, 1)},
		v = create_sprite_state(.Box),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_CHEST_MONSTER + {0, 2},
		n = "Monster in a box",
		talk = proc(id: Id) {monster_in_a_box(id, 2)},
		v = create_sprite_state(.Box),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_CHEST_MONSTER + {0, 3},
		n = "Monster in a box",
		talk = proc(id: Id) {monster_in_a_box(id, 3)},
		v = create_sprite_state(.Box),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_CHEST_MONSTER + {0, 4},
		n = "Monster in a box",
		talk = proc(id: Id) {monster_in_a_box(id, 4)},
		v = create_sprite_state(.Box),
	})

	add_world_entity(
		Entity {
			id = new_id(),
			tile = LEVEL_0_SIGN,
			n = "Lorem Ipsum sign",
			talk = proc(_: Id) {
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
			},
			v = create_sprite_state(.Sign),
		},
	)

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_JUKEBOX,
		n = "Jukebox",
		talk = proc(_: Id) {
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
					Skip_If_Choice{22, 1},
					Append_Text{"Sure. You still gotta put money in it, though. It's similar to a jukebox in that way."},
					Append_Choice{"Ugh, fine. $3"},
					Append_Choice{"What? No way."},
					Get_Choice{},
					Clear_Text{},
					Skip_If_Choice{16, 1},
					Skip_If_Have_Money{2, 3},
					Append_Text{"You can't afford it!"},
					Skip{13},
					Lose_Money{3},
					Music_Fade_Down{},
					Curtain_Down{},
					Heal_Party{},
					Pause_Runner{.75},
					Play_Sound{sound = .Warp},
					Pause_Runner{.75},
					Curtain_Up{},
					Music_Fade_Up{},
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
		},
		v = create_sprite_state(.Jukebox),
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_0_SAVE,
		ghost = true,
		n = "Level_0_Save",
		v = create_sprite_state(.Save_Point),
		trap = proc(id: Id) {save_point(id, .Level_0)},
	})

	play_music(&music_state, .Town)

	if !get_game_data(Bool_Datum.Introduction) {
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
}
