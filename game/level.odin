package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"

PLAYER_ID: Id = 0

current_level : Level
routes: [][]Tile_Coord

add_pc_entity :: proc(tile: Tile_Coord, face: Face) {
	pc_entity = hm.add(
		&entities,
		Entity {
			id = PLAYER_ID,
			face = face,
			tile = tile,
			speed = 3,
			n = "Player",
			state = Control{},
			v = facing_animation_create(
				.Protagonist_World_Left,
				.Protagonist_World_Right,
				.Protagonist_World_Up,
				.Protagonist_World_Down,
				face,
			),
			z = Z_MAX,
		},
	)
}

Level :: enum {
	LEVEL_0,
	LEVEL_1,
	LEVEL_2,
}

start_level :: proc(l: Level) {
	hm.clear(&entities)
	unload_map()
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)
	switch l {
	case .LEVEL_0:
		map_dim = {LEVEL_0_WIDTH, LEVEL_0_HEIGHT}
		render_level_0()
		routes = LEVEL_0_ROUTES
		start_level_0()
	case .LEVEL_1:
		map_dim = {LEVEL_1_WIDTH, LEVEL_1_HEIGHT}
		render_level_1()
		routes = LEVEL_1_ROUTES
		start_level_1()
	case .LEVEL_2:
		map_dim = {LEVEL_2_WIDTH, LEVEL_2_HEIGHT}
		render_level_2()
		routes = LEVEL_2_ROUTES
		start_level_2()
	}
	camera_entity = pc_entity
	time.stopwatch_stop(&stopwatch)
	fmt.println("Loaded level", l, "in", time.stopwatch_duration(stopwatch))
	current_level = l
}
