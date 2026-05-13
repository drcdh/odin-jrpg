package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"

PLAYER_ID: Id = 0

current_level: Level
prev_level: Level
prev_level_tile: Tile_Coord

level_firstgids: []int
level_tilesets: []Tileset_Id
routes: [][]Tile_Coord

CHANGE_LEVEL := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Next_Level{},
	Curtain_Up{},
	End{},
}

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
	LEVEL_OVERWORLD,
}

start_level :: proc(l: Level) {
	hm.clear(&entities)
	unload_map()
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)
	switch l {
	case .LEVEL_0:
		map_dim = {LEVEL_0_WIDTH, LEVEL_0_HEIGHT}
		level_firstgids = LEVEL_0_FIRSTGIDS[:]
		level_tilesets = LEVEL_0_TILESETS[:]
		routes = LEVEL_0_ROUTES
		start_level_0()
		render_level_0()
	case .LEVEL_1:
		map_dim = {LEVEL_1_WIDTH, LEVEL_1_HEIGHT}
		level_firstgids = LEVEL_1_FIRSTGIDS[:]
		level_tilesets = LEVEL_1_TILESETS[:]
		routes = LEVEL_1_ROUTES
		start_level_1()
		render_level_1()
	case .LEVEL_2:
		map_dim = {LEVEL_2_WIDTH, LEVEL_2_HEIGHT}
		level_firstgids = LEVEL_2_FIRSTGIDS[:]
		level_tilesets = LEVEL_2_TILESETS[:]
		routes = LEVEL_2_ROUTES
		start_level_2()
		render_level_2()
	case .LEVEL_OVERWORLD:
		map_dim = {LEVEL_OVERWORLD_WIDTH, LEVEL_OVERWORLD_HEIGHT}
		level_firstgids = LEVEL_OVERWORLD_FIRSTGIDS[:]
		level_tilesets = LEVEL_OVERWORLD_TILESETS[:]
		routes = LEVEL_OVERWORLD_ROUTES
		start_level_overworld()
		render_level_overworld()
	}
	camera_entity = pc_entity
	time.stopwatch_stop(&stopwatch)
	fmt.println("Loaded level", l, "in", time.stopwatch_duration(stopwatch))
	fmt.println("Level map dimensions are", map_dim)
	fmt.println("Level map uses", len(level_tilesets), "tilesets")
	current_level = l
}
