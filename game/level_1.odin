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

GUY_SCRIPT := [?]Event{
	Set_Entity_Busy{id = PLAYER_ID, busy=true},
	Set_Entity_Busy{id = GUY_ID, busy = true},
	Append_Text{text="Erm, hello, $player."},
	Clear_Text{},
	Append_Text{text="Have you met Dude yet? "},
	Skip_If{2, .Met_Dude},
	Append_Text{text="No? Well."},
	Skip{1},
	Append_Text{text="Yes? Very good."},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = GUY_ID, busy = false},
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
		}
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
}
