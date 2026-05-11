package game

import hm "core:container/handle_map"
import "core:fmt"

import rl "vendor:raylib"

VIEW_TILES_W :: 16
VIEW_TILES_H :: 14

Z_MAX :: 3

entities: hm.Static_Handle_Map(128, Entity, Entity_Handle)
pc_entity: Entity_Handle
runner := Runner{}

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

	rl.EndMode2D()
}

update_world :: proc(dt: f32) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		update_entity(dt, e)
	}
}

activate_entity_talk_script :: proc(h: Entity_Handle) {
	start_script(hm.get(&entities, h).talk)
}

activate_entity_trap_script :: proc(h: Entity_Handle) {
	start_script(hm.get(&entities, h).trap)
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
		if e.tile == t && e.id != skip {
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
			fmt.println("set entity busy", e.n, e.busy)
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
