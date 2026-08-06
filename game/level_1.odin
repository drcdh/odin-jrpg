#+private file
package game

@(private)
LEVEL_1_OVERLAY :: true

DOOR_ID :: 1000
GUY_ID :: 80
WOMAN_ID :: 90
WARP_2_ID :: 300

door_knock :: proc(id: Id) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Pause_Runner{.5},
			Play_Sound{sound = .Door_Knock},
			Pause_Runner{1},
			Play_Sound{sound = .Door_Open},
			Set_Entity_Disabled{id = WOMAN_ID, disabled = false},
			Pause_Runner{.5},
			Skip_If{9, .Met_Woman},
			Append_Text{"We don't want any."},
			Pause_Runner{.5},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Disabled{id = WOMAN_ID, disabled = true},
			Play_Sound{sound = .Door_Shut},
			Pause_Runner{.1},
			Set_Bool{k = .Met_Woman, v = true},
			Skip{6},
			Append_Text{"Oh, alright."},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Disabled{id = WOMAN_ID, disabled = true},
			Toggle_Party_Member{.Assassin, true},
			Set_Entity_Talk_Script{id, nil},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

@(private)
start_level_1 :: proc() {
	add_pc_entity(LEVEL_1_PLAYER_SPAWN, .Right)

	add_world_entity(Entity {
		id = GUY_ID,
		face = .Down,
		tile = LEVEL_1_GUY_SPAWN,
		n = "Guy",
		talk = proc(id: Id) {
			queue_events(
				[]Event {
					Set_Entity_Busy{PLAYER_ID, true},
					Set_Entity_Busy{id, true},
					Set_Entity_Face_Party{id},
					Append_Text{"Erm, hello, $player."},
					Clear_Text{},
					Skip_If{2, .Met_Dude},
					Append_Text{"Have you met Dude yet? No? Well."},
					Skip{1},
					Append_Text{"Have you met Dude yet? Very good."},
					Close_Dialogue{},
					Clear_Text{},
					Set_Entity_Tag{id, .Down},
					Set_Entity_Busy{id, false},
					Set_Entity_Busy{PLAYER_ID, false},
					End{},
				},
			)
		},
		v = create_sprite_state(.Dude_World),
	})

	add_world_entity(Entity {
		id = WARP_2_ID,
		ghost = true,
		tile = LEVEL_1_WARP_SPAWN,
		n = "warp",
		trap = proc(_: Id) {warp_to_level(.Level_2)},
		v = create_sprite_state(.Warp),
	})

	add_world_entity(
		Entity {
			id = WOMAN_ID,
			disabled = true,
			face = .Down,
			ghost = true,
			tile = LEVEL_1_DOOR,
			v = create_sprite_state(.Woman_World),
		},
	)

	add_world_entity(
		Entity{id = DOOR_ID, tile = LEVEL_1_DOOR, talk = nil if game_data.bool_data[Bool_Datum.Met_Woman] else door_knock},
	)

	add_world_entity(Entity{id = 1, tile = LEVEL_1_FIRE, v = create_sprite_state(.Fire)})

	play_music(&music_state, .Town)
}
