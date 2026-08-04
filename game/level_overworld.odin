#+private file
package game

import "core:fmt"

@(private)
LEVEL_OVERWORLD_OVERLAY :: false

@(private)
start_level_overworld :: proc() {
	fmt.println(prev_level, prev_level_tile, current_level)
	party_tile: Tile_Coord
	switch prev_level {
	case .LEVEL_0:
		party_tile = LEVEL_OVERWORLD_GROVE
	case .LEVEL_1:
		party_tile = LEVEL_OVERWORLD_HOUSE
	case .LEVEL_2:
		party_tile = LEVEL_OVERWORLD_QUARRY
	case .LEVEL_CAVE:
		party_tile = LEVEL_OVERWORLD_CAVE_ENTRANCE if prev_level_tile == LEVEL_CAVE_ENTRANCE else LEVEL_OVERWORLD_CAVE_EXIT
	case .LEVEL_OVERWORLD:
	// ?
	}
	add_pc_entity(party_tile, .Down)

	add_world_entity(
		Entity {
			id = BOAT_ID,
			tile = game_data.boat_coord,
			n = "boat",
			speed = 4,
			talk = board_boat,
			v = facing_animation_create(.Boat_Left, .Boat_Right, .Boat_Up, .Boat_Down, .Right),
		},
	)

	boat_handle = get_world_entity_handle(BOAT_ID)

	add_world_entity(Entity {
		id = 2000,
		ghost = true,
		n = "grove",
		tile = LEVEL_OVERWORLD_GROVE,
		trap = proc() {egress(.LEVEL_0)},
	})

	add_world_entity(Entity {
		id = 2001,
		ghost = true,
		n = "house",
		tile = LEVEL_OVERWORLD_HOUSE,
		trap = proc() {egress(.LEVEL_1)},
	})

	add_world_entity(Entity {
		id = 2002,
		ghost = true,
		n = "quarry",
		tile = LEVEL_OVERWORLD_QUARRY,
		trap = proc() {egress(.LEVEL_2)},
	})

	add_world_entity(Entity {
		id = 2003,
		ghost = true,
		n = "cave_entrance",
		tile = LEVEL_OVERWORLD_CAVE_ENTRANCE,
		trap = proc() {egress(.LEVEL_CAVE)},
	})

	add_world_entity(Entity {
		id = 2004,
		ghost = true,
		n = "cave_exit",
		tile = LEVEL_OVERWORLD_CAVE_EXIT,
		trap = proc() {egress(.LEVEL_CAVE)},
	})

	play_music(&music_state, .Overworld)
}
