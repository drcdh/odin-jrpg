package game

import hm "core:container/handle_map"

BOAT_ID :: 77

BOARD_BOAT := [?]Event {
	Set_Entity_Disabled{id = PLAYER_ID, disabled = true},
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

start_level_overworld :: proc() {
	add_pc_entity(LEVEL_OVERWORLD_GROVE+{1,1}, .Down)

	boat_handle = hm.add(
		&entities,
		Entity {
			id = BOAT_ID,
			tile = game_data.boat_coord,
			n = "boat",
			speed = 4,
			talk = BOARD_BOAT[:],
			v = facing_animation_create(.Boat_Left, .Boat_Right, .Boat_Up, .Boat_Down, .Right),
		}
	)
}
