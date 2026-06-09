package game
import hm "core:container/handle_map"
import "core:fmt"

BOAT_ID :: 77

BOARD_BOAT := [?]Event {
	Set_Entity_Disabled{id = PLAYER_ID, disabled = true},
	Set_Entity_Busy{id = BOAT_ID, busy = false},
	Set_Boat_Control{},
	End{},
}

LEAVE_BOAT := [?]Event {
	Set_Entity_Busy{id = BOAT_ID, busy = true},
	Move_Entity_Here{id = PLAYER_ID},
	Set_Entity_Disabled{id = PLAYER_ID, disabled = false},
	Set_Party_Control{},
	End{},
}

enter_grove := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Level{level = .LEVEL_0},
	Curtain_Up{},
	End{},
}

enter_house := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Level{level = .LEVEL_1},
	Curtain_Up{},
	End{},
}

enter_quarry := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Level{level = .LEVEL_2},
	Curtain_Up{},
	End{},
}

enter_cave := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Level{level = .LEVEL_CAVE},
	Curtain_Up{},
	End{},
}

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

	boat_handle = hm.add(
		&entities,
		Entity {
			id = BOAT_ID,
			tile = game_data.boat_coord,
			n = "boat",
			speed = 4,
			talk = BOARD_BOAT[:],
			v = facing_animation_create(.Boat_Left, .Boat_Right, .Boat_Up, .Boat_Down, .Right),
		},
	)

	_ = hm.add(
		&entities,
		Entity{id = 2000, ghost = true, n = "grove", tile = LEVEL_OVERWORLD_GROVE, trap = enter_grove[:]},
	)

	_ = hm.add(
		&entities,
		Entity{id = 2001, ghost = true, n = "house", tile = LEVEL_OVERWORLD_HOUSE, trap = enter_house[:]},
	)

	_ = hm.add(
		&entities,
		Entity{id = 2002, ghost = true, n = "quarry", tile = LEVEL_OVERWORLD_QUARRY, trap = enter_quarry[:]},
	)

	_ = hm.add(
		&entities,
		Entity{id = 2003, ghost = true, n = "cave_entrance", tile = LEVEL_OVERWORLD_CAVE_ENTRANCE, trap = enter_cave[:]},
	)

	_ = hm.add(
		&entities,
		Entity{id = 2004, ghost = true, n = "cave_exit", tile = LEVEL_OVERWORLD_CAVE_EXIT, trap = enter_cave[:]},
	)

	play_music(&music_state, .Overworld)
}
