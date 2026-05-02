package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

entities: hm.Static_Handle_Map(128, Entity, Entity_Handle)
m: Map
pc_entity: Entity_Handle
runner := Runner{}

draw_world :: proc() {
	draw_map(m)
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if !e.disabled {
			draw_entity(e)
		}
	}
}

update_world :: proc(dt: f32) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		update_entity(dt, e)
	}
}

draw_dialogue :: proc() {
	if dialogue_show {
		c_str := strings.clone_to_cstring(dialogue_str, context.temp_allocator)
		draw_menu({10, 10, 300, 100})
		rl.DrawTextEx(font, c_str, {20, 20}, 18, 0, TEXT_COLOR)
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
