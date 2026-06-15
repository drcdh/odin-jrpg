package game

import hm "core:container/handle_map"

@(private = "file")
MAP_WIDTH :: LEVEL_2_WIDTH
@(private = "file")
MAP_HEIGHT :: LEVEL_2_HEIGHT

LEVEL_2_OVERLAY :: true

TRAP_ID :: 665
TRAP_BADDY_ID :: 666

WARP_TO_0 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_0},
	Curtain_Up{},
	End{},
}

TRAP_BADDY_ACTIVATE := [?]Event {
	Set_Entity_State{id = TRAP_BADDY_ID, state = Approach_Entity{id = PLAYER_ID}},
	Remove_Entity{TRAP_ID},
	End{},
}

TRAP_BADDY_ENCOUNTER := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Start_Encounter{encounter = 0},
	Remove_Entity{TRAP_BADDY_ID},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

start_level_2 :: proc() {
	add_pc_entity(LEVEL_2_PLAYER_SPAWN, .Down)

	for i := 1; i <= MAP_WIDTH - 3; i += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 100 + i,
				tile = Tile_Coord{i, 1},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 200 + i,
				tile = Tile_Coord{i, MAP_HEIGHT - 3},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 3},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}
	for j := 3; j <= MAP_HEIGHT - 5; j += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 300 + j,
				tile = Tile_Coord{1, j},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 0},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 400 + j,
				tile = Tile_Coord{MAP_WIDTH - 3, j},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 2},
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
			tile = LEVEL_2_WARP_SPAWN,
			n = "warp",
			trap = WARP_TO_0[:],
			v = animation_create(.Warp),
		},
	)

	_ = hm.add(
		&entities,
		Entity{id = TRAP_ID, ghost = true, tile = LEVEL_2_TRAP_SPAWN, n = "trap", trap = TRAP_BADDY_ACTIVATE[:]},
	)

	_ = hm.add(
		&entities,
		Entity {
			id = TRAP_BADDY_ID,
			ghost = true,
			face = .Right,
			tile = LEVEL_2_BADDY_SPAWN,
			n = "baddy",
			speed = 3,
			trap = TRAP_BADDY_ENCOUNTER[:],
			v = facing_animation_create(.Baddy_World_Left, .Baddy_World_Right, .Baddy_World_Up, .Baddy_World_Down, .Right),
			z = Z_MAX,
		},
	)

	play_music(&music_state, .Town)
}
