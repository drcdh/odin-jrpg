package game

import hm "core:container/handle_map"
import "core:fmt"

import rl "vendor:raylib"

entities: hm.Static_Handle_Map(128, Entity, Entity_Handle)
m: Map
pc_entity: Entity_Handle
runner := Runner{}

camera_entity: Entity_Handle

draw_world :: proc() {
	world_camera : rl.Camera2D
	if camera, ok := hm.get(&entities, camera_entity); ok {
	world_camera = {
		zoom = 2,
		target = get_entity_pixel(camera^),
		offset = { WINDOW_WIDTH/2, WINDOW_HEIGHT/2 },
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
	start_script(hm.get(&entities, h).script)
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

set_entity_script :: proc(e_id: Id, script: []Event) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.id == e_id {
			e.script = script
			fmt.println("set entity with script of len", e.n, len(e.script))
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
