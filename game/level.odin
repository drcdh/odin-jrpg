package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"

PLAYER_ID: Id = 0

level_firstgids: []int
level_map_wrap: bool
level_routes: [][]Tile_Coord
level_tilesets: []Tileset_Id

CHANGE_LEVEL := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Next_Level{},
	Curtain_Up{},
	End{},
}

add_pc_entity :: proc(tile: Tile_Coord, face: Face) {
	party_handle = hm.add(
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
	pc_entity = party_handle
}

start_level :: proc(l: Level) {
	hm.clear(&entities)
	unload_map()
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)
	init_level(l)
	level_map_wrap = l == .LEVEL_OVERWORLD
	camera_entity = pc_entity
	time.stopwatch_stop(&stopwatch)
	fmt.printfln("% 4d: Loaded level %w in %s", frame_count, l, time.stopwatch_duration(stopwatch))
	fmt.printfln("% 4d: Level map dimensions are %w", frame_count, map_dim)
	fmt.printfln("% 4d: Level map uses %d tilesets", frame_count, len(level_tilesets))
	current_level = l
}
