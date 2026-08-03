package game

LEVEL_CAVE_OVERLAY :: false

LEAVE_CAVE := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Down{},
	Start_Level{level = .LEVEL_OVERWORLD},
	Curtain_Up{},
	End{},
}

start_level_cave :: proc() {
	add_pc_entity(LEVEL_CAVE_EXIT if prev_level_tile == LEVEL_OVERWORLD_CAVE_EXIT else LEVEL_CAVE_ENTRANCE, .Down)

	add_world_entity(Entity{id = 900, ghost = true, tile = LEVEL_CAVE_ENTRANCE, trap = LEAVE_CAVE[:]})

	add_world_entity(Entity{id = 901, ghost = true, tile = LEVEL_CAVE_EXIT, trap = LEAVE_CAVE[:]})

	add_world_entity(Entity{id = 5, tile = LEVEL_CAVE_FIRE, v = animation_create(.Fire)})

	play_music(&music_state, .None)
}
