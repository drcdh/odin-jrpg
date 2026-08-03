package game

import rl "vendor:raylib"

VIEW_TILES_W :: 16
VIEW_TILES_H :: 14

Z_MAX :: 3

boat_mode: bool
boat_handle: Entity_Handle
party_handle: Entity_Handle
pc_handle: Entity_Handle

current_level: Level
next_level: Level
prev_level: Level
prev_level_tile: Tile_Coord

camera_handle: Entity_Handle

draw_world :: proc() {
	world_camera: rl.Camera2D
	if camera := get_world_entity(camera_handle); camera != nil {
		world_camera = {
			zoom   = 1,
			target = get_entity_pixel(camera^) + tile_dim / 2,
			offset = view_dim / 2,
		}
	}

	rl.BeginMode2D(world_camera)
	draw_map()
	draw_world_entities()
	draw_overlay()
	rl.EndMode2D()

	// pc := hm.get(&entities, pc_handle)
	// rl.DrawText(
	// 	// fmt.ctprintf("%s [%d,%d] %w", pc.n, pc.tile.x, pc.tile.y, pc.state),
	// 	fmt.ctprint(// fmt.ctprintf("%s %w %w", pc.n, pc.state, pc.k),
	// 		pc.n,
	// 		pc.state,
	// 		pc.k.tile.x,
	// 		pc.k.tile.y,
	// 		pc.k.moving,
	// 		pc.k.offset,
	// 		pc.k.offset_ease,
	// 	),
	// 	0,
	// 	i32(view_dim.y - tile_size),
	// 	24,
	// 	rl.BLACK,
	// )
}

update_world :: proc(dt: f32) {
	update_world_entities(dt)
	update_overlay()
}

// activate_entity_trap_script_handle :: proc(h: Entity_Handle) {
// 	activate_entity_trap_script_entity(hm.get(&entities, h))
// }
//
// activate_entity_trap_script :: proc {
// 	activate_entity_trap_script_entity,
// 	activate_entity_trap_script_handle,
// }

set_party_control :: proc() {
	boat := get_world_entity(BOAT_ID)
	game_data.boat_coord = boat.tile
	boat.state = nil
	boat_mode = false
	party := get_world_entity(PLAYER_ID)
	party.disabled = false
	party.face = boat.face
	party.state = Control{}
	pc_handle = party_handle
	camera_handle = party_handle
}

pc_busy :: proc() -> bool {
	if pc := get_world_entity(pc_handle); pc != nil {
		return pc.busy
	}
	return true
}
