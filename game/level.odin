package game

import "core:fmt"
import "core:time"

PLAYER_ID :: 0

level_firstgids: []int
level_map_wrap: bool
level_proc: proc(_: f32)
level_routes: [][]Tile_Coord
level_tilesets: []Tileset_Id

change_level :: proc(level: Level) {
	queue_events(
		[]Event{Set_Entity_Busy{id = PLAYER_ID, busy = true}, Curtain_Down{}, Start_Level{level}, Curtain_Up{}, End{}},
	)
}

add_pc_entity :: proc(tile: Tile_Coord, face: Face) {
	add_world_entity(
		Entity {
			id = PLAYER_ID,
			face = face,
			tile = tile,
			speed = 3,
			n = "Player",
			state = Control{},
			v = create_sprite_state(.Protagonist_World, face),
			z = Z_MAX,
		},
	)
	party_handle = get_world_entity_handle(PLAYER_ID)
	pc_handle = party_handle
}

start_level :: proc(l: Level) {
	if pc := get_world_entity(pc_handle); pc != nil {
		prev_level_tile = pc.tile
	}
	prev_level = current_level
	current_level = l
	level_map_wrap = l == .Level_Overworld
	clear_world_entities()
	unload_map()
	darkness = 0
	level_proc = nil
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)
	init_level(l)
	camera_handle = pc_handle
	time.stopwatch_stop(&stopwatch)
	fmt.printfln("% 4d: Loaded level %w in %s", frame_count, l, time.stopwatch_duration(stopwatch))
	fmt.printfln("% 4d: Level map dimensions are %w", frame_count, map_dim)
	fmt.printfln("% 4d: Level map uses %d tilesets", frame_count, len(level_tilesets))
}

restart_level :: proc() {
	start_level(current_level)
}
