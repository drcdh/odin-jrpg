#+private file
package game

@(private)
LEVEL_CAVE_OVERLAY :: false

leave_cave :: proc() {egress(.LEVEL_OVERWORLD)}

@(private)
start_level_cave :: proc() {
	add_pc_entity(LEVEL_CAVE_EXIT if prev_level_tile == LEVEL_OVERWORLD_CAVE_EXIT else LEVEL_CAVE_ENTRANCE, .Down)

	add_world_entity(Entity{id = 900, ghost = true, tile = LEVEL_CAVE_ENTRANCE, trap = leave_cave})

	add_world_entity(Entity{id = 901, ghost = true, tile = LEVEL_CAVE_EXIT, trap = leave_cave})

	add_world_entity(Entity {
		id = 5,
		tile = LEVEL_CAVE_FIRE_0,
		v = animation_create(.Fire),
		talk = proc() {
			set_world_entity_light(PLAYER_ID, 3)
		},
		light = 3,
	})

	add_world_entity(Entity {
		id = 6,
		tile = LEVEL_CAVE_FIRE_1,
		v = animation_create(.Fire),
		talk = proc() {
			set_world_entity_light(PLAYER_ID, 3)
		},
		light = 3,
	})

	add_world_entity(Entity {
		id = 7,
		tile = LEVEL_CAVE_FIRE_2,
		v = animation_create(.Fire),
		talk = proc() {
			set_world_entity_light(PLAYER_ID, 3)
		},
		light = 3,
	})

	add_world_entity(Entity {
		id = 8,
		tile = LEVEL_CAVE_FIRE_3,
		v = animation_create(.Fire),
		talk = proc() {
			set_world_entity_light(PLAYER_ID, 3)
		},
		light = 3,
	})

	level_proc = proc(dt: f32) {
		pc := get_world_entity(PLAYER_ID)
		dl := f16(dt / 10)
		pc.light = 0 if pc.light < dl else pc.light - dl
	}

	play_music(&music_state, .None)

	darkness = 245

	text_popup("Damn, it's dark in here!")
	// set_world_entity_light(PLAYER_ID, 3.0)
}
