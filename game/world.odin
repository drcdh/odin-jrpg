package game

import hm "core:container/handle_map"
import "core:fmt"

import rl "vendor:raylib"

VIEW_TILES_W :: 16
VIEW_TILES_H :: 14

entities: hm.Static_Handle_Map(128, Entity, Entity_Handle)
m: Map
pc_entity: Entity_Handle
runner := Runner{}

camera_entity: Entity_Handle

draw_world :: proc() {
	world_camera: rl.Camera2D
	if camera, ok := hm.get(&entities, camera_entity); ok {
		world_camera = {
			zoom   = 1,
			target = get_entity_pixel(camera^),
			offset = view_dim / 2,
		}
	}

	rl.BeginMode2D(world_camera)

	draw_map(m)
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if !e.disabled {
			draw_entity(e)
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

activate_entity :: proc(h: Entity_Handle) {
	start_script(hm.get(&entities, h).activate_script)
}

get_entity_at_tile :: proc(t: Tile_Coord) -> Maybe(Entity_Handle) {
	it := hm.iterator_make(&entities)
	for e, h in hm.iterate(&it) {
		if e.k.tile == t {
			return h
		}
	}
	return nil
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

set_entity_activate_script :: proc(e_id: Id, script: []Event) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.activate_script = script
		}
	}
}

set_entity_overlap_script :: proc(e_id: Id, script: []Event) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.overlap_script = script
		}
	}
}

set_entity_tap_script :: proc(e_id: Id, script: []Event) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.tap_script = script
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

set_entity_visual :: proc{
	set_entity_visual_texture,
}
