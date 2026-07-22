package game

import hm "core:container/handle_map"
import "core:fmt"

import rl "vendor:raylib"

VIEW_TILES_W :: 16
VIEW_TILES_H :: 14

Z_MAX :: 3

boat_mode: bool
boat_handle: Entity_Handle
entities: hm.Static_Handle_Map(128, Entity, Entity_Handle)
party_handle: Entity_Handle
pc_entity: Entity_Handle

current_level: Level
next_level: Level
prev_level: Level
prev_level_tile: Tile_Coord

camera_entity: Entity_Handle

at_z :: proc(k: Kinematics, z: int) -> bool {
	return (z == 0 && k.z <= 0) || (z == k.z) || (z == Z_MAX && k.z >= Z_MAX)
}

draw_world :: proc() {
	world_camera: rl.Camera2D
	if camera, ok := hm.get(&entities, camera_entity); ok {
		world_camera = {
			zoom   = 1,
			target = get_entity_pixel(camera^) + tile_dim / 2,
			offset = view_dim / 2,
		}
	}

	rl.BeginMode2D(world_camera)

	draw_map()

	for z in 0 ..= Z_MAX {
		it := hm.iterator_make(&entities)
		for e, _ in hm.iterate(&it) {
			if !e.disabled && at_z(e, z) {
				draw_entity(e)
			}
		}
	}

	draw_overlay()

	rl.EndMode2D()

	// pc := hm.get(&entities, pc_entity)
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
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		update_entity(dt, e)
	}
	update_overlay()
}

activate_entity_talk_script :: proc(h: Entity_Handle) {
	queue_events(hm.get(&entities, h).talk)
}

activate_entity_trap_script_entity :: proc(e: ^Entity) {
	queue_events(e.trap)
}

activate_entity_trap_script_handle :: proc(h: Entity_Handle) {
	activate_entity_trap_script_entity(hm.get(&entities, h))
}

activate_entity_trap_script :: proc {
	activate_entity_trap_script_entity,
	activate_entity_trap_script_handle,
}

get_entity_p :: proc(id: Id) -> ^Entity {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == id {
			return e
		}
	}
	return nil
}

get_entity :: proc(id: Id) -> Maybe(Entity_Handle) {
	it := hm.iterator_make(&entities)
	for e, h in hm.iterate(&it) {
		if e.id == id && !e.disabled {
			return h
		}
	}
	return nil
}

get_entity_at_tile :: proc(t: Tile_Coord, skip := NULL_ID) -> Maybe(Entity_Handle) {
	it := hm.iterator_make(&entities)
	for e, h in hm.iterate(&it) {
		if e.tile == t && !e.disabled && e.id != skip {
			return h
		}
	}
	return nil
}

remove_entity :: proc(e_id: Id) {
	hr: Entity_Handle
	it := hm.iterator_make(&entities)
	for e, h in hm.iterate(&it) {
		if e.id == e_id {
			hr = h
		}
	}
	hm.remove(&entities, hr)
}

set_entity_busy :: proc(e_id: Id, busy: bool) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.busy = busy
			return
		}
	}
	fmt.println("didn't find entity with id", e_id)
}

set_entity_disabled :: proc(e_id: Id, disabled: bool) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.disabled = disabled
			return
		}
	}
	fmt.println("didn't find entity with id", e_id)
}

set_entity_talk_script :: proc(e_id: Id, script: []Event) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.talk = script
		}
	}
}

set_entity_trap_script :: proc(e_id: Id, script: []Event) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.trap = script
		}
	}
}

set_entity_state :: proc(e_id: Id, state: State) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.state = state
		}
	}
}

set_entity_visual_texture :: proc(e_id: Id, texture: Texture_Name) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.v = texture
		}
	}
}

set_entity_visual :: proc {
	set_entity_visual_texture,
}

set_party_control :: proc() {
	boat := get_entity_p(BOAT_ID)
	game_data.boat_coord = boat.tile
	boat.state = nil
	boat_mode = false
	party := get_entity_p(PLAYER_ID)
	party.disabled = false
	party.face = boat.face
	party.state = Control{}
	pc_entity = party_handle
	camera_entity = party_handle
}

pc_busy :: proc() -> bool {
	if pc, ok := hm.get(&entities, pc_entity); ok {
		return pc.busy
	}
	return true
}
