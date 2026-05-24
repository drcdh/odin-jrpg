package game

import hm "core:container/handle_map"

WARP_TO_2 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_2},
	Curtain_Up{},
	End{},
}

GUY_ID :: 80
WOMAN_ID :: 90

GUY_SCRIPT := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Set_Entity_Busy{id = GUY_ID, busy = true},
	Append_Text{text = "Erm, hello, $player."},
	Clear_Text{},
	Skip_If{2, .Met_Dude},
	Append_Text{text = "Have you met Dude yet? No? Well."},
	Skip{1},
	Append_Text{text = "Have you met Dude yet? Very good."},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = GUY_ID, busy = false},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

DOOR_KNOCK := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Pause_Runner{.5},
	Play_Sound{.Door_Knock},
	Pause_Runner{1},
	Play_Sound{.Door_Open},
	Set_Entity_Disabled{id = WOMAN_ID, disabled = false},
	Pause_Runner{.5},
	Skip_If{9, .Met_Woman},
	Append_Text{text = "We don't want any."},
	Pause_Runner{.5},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Disabled{id = WOMAN_ID, disabled = true},
	Play_Sound{.Door_Shut},
	Pause_Runner{.1},
	Set_Bool{k = .Met_Woman, v = true},
	Skip{5},
	Append_Text{text = "Oh, alright."},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Disabled{id = WOMAN_ID, disabled = true},
	Toggle_Party_Member{.Assassin, true},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

start_level_1 :: proc() {
	add_pc_entity(LEVEL_1_PLAYER_SPAWN, .Right)

	_ = hm.add(
		&entities,
		Entity {
			id = GUY_ID,
			face = .Down,
			tile = LEVEL_1_GUY_SPAWN,
			n = "Guy",
			talk = GUY_SCRIPT[:],
			v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
		},
	)
	_ = hm.add(
		&entities,
		Entity {
			id = 3,
			ghost = true,
			tile = LEVEL_1_WARP_SPAWN,
			n = "warp",
			trap = WARP_TO_2[:],
			v = animation_create(.Warp),
		},
	)

	_ = hm.add(
		&entities,
		Entity {
			id = WOMAN_ID,
			disabled = true,
			face = .Down,
			ghost = true,
			tile = LEVEL_1_DOOR,
			v = facing_animation_create(.Woman_World_Left, .Woman_World_Right, .Woman_World_Up, .Woman_World_Down, .Down),
		},
	)

	_ = hm.add(&entities, Entity{id = 1000, tile = LEVEL_1_DOOR, talk = DOOR_KNOCK[:]})
}
