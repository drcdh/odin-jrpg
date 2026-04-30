package game

import hm "core:container/handle_map"
import "core:fmt"

entities: hm.Static_Handle_Map(128, Entity, Entity_Handle)
m: Map
pc_entity: Entity_Handle
runner := Runner{}

quitting := false // todo: transitions

get_entity_at_tile :: proc(t: Tile_Coord) -> Maybe(Entity_Handle) {
	it := hm.iterator_make(&entities)
	for e, h in hm.iterate(&it) {
		if e.k.tile == t {
			return h
		}
	}
	return nil
}

activate_entity :: proc(h: Entity_Handle) {
	start_script(hm.get(&entities, h).script)
}

start_script :: proc(script: []Event) {
	if script != nil {
		fmt.println("starting script of len", len(script))
		runner.script = script
		runner.state = Continue{}
		runner.step = -1
	}
}

draw_level :: proc() {
	draw_map(m)
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if !e.disabled {
			draw_entity(e)
		}
	}
}

update_level :: proc(dt: f32) {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		update_entity(dt, e)
	}
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
