#+private file
package game

MAP_WIDTH :: LEVEL_2_WIDTH
MAP_HEIGHT :: LEVEL_2_HEIGHT

@(private)
LEVEL_2_OVERLAY :: true

TRAP_BADDY_ID :: 666

@(private)
start_level_2 :: proc() {
	add_pc_entity(LEVEL_2_PLAYER_SPAWN, .Down)

	for i := 1; i <= MAP_WIDTH - 3; i += 2 {
		add_world_entity(
			Entity {
				id = new_id(),
				tile = Tile_Coord{i, 1},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 1},
				v = create_sprite_state(.Dude_World),
				z = Z_MAX,
			},
		)
		add_world_entity(
			Entity {
				id = new_id(),
				tile = Tile_Coord{i, MAP_HEIGHT - 3},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 3},
				v = create_sprite_state(.Dude_World),
				z = Z_MAX,
			},
		)
	}
	for j := 3; j <= MAP_HEIGHT - 5; j += 2 {
		add_world_entity(
			Entity {
				id = new_id(),
				tile = Tile_Coord{1, j},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 0},
				v = create_sprite_state(.Dude_World),
				z = Z_MAX,
			},
		)
		add_world_entity(
			Entity {
				id = new_id(),
				tile = Tile_Coord{MAP_WIDTH - 3, j},
				speed = 2,
				state = Pacing{route = LEVEL_2_CONGA_LINE, pause = 1, step = 2},
				v = create_sprite_state(.Dude_World),
				z = Z_MAX,
			},
		)
	}

	add_world_entity(Entity {
		id = new_id(),
		ghost = true,
		tile = LEVEL_2_WARP_SPAWN,
		n = "warp",
		trap = proc(_: Id) {warp_to_level(.Level_0)},
		v = create_sprite_state(.Warp),
	})

	add_world_entity(Entity {
		id = new_id(),
		ghost = true,
		tile = LEVEL_2_TRAP_SPAWN,
		n = "trap",
		trap = proc(id: Id) {
			set_world_entity_state(TRAP_BADDY_ID, Approach_Entity{id = PLAYER_ID})
			remove_world_entity(id)
		},
	})

	add_world_entity(Entity {
		id = TRAP_BADDY_ID,
		ghost = true,
		face = .Right,
		tile = LEVEL_2_BADDY_SPAWN,
		n = "baddy",
		speed = 3,
		trap = proc(id: Id) {
			queue_events(
				[]Event {
					Set_Entity_Busy{id = PLAYER_ID, busy = true},
					Start_Encounter{encounter = 0},
					Remove_Entity{id},
					Curtain_Up{.Battle},
					Set_Entity_Busy{id = PLAYER_ID, busy = false},
					End{},
				},
			)
		},
		v = create_sprite_state(.Baddy_World, .Right),
		z = Z_MAX,
	})

	add_world_entity(Entity {
		id = new_id(),
		tile = LEVEL_2_SAVE,
		ghost = true,
		n = "Level_2_Save",
		v = create_sprite_state(.Save_Point, .Active if get_game_data(Bool_Datum.Save_Point_Level_2) else .Inactive),
		trap = proc(id: Id) {save_point(id, .Level_2, .Save_Point_Level_2)},
	})

	play_music(&music_state, .Town)
}
