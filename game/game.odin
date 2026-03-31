package game

import "core:fmt"

entities: [dynamic]Entity
m: Map
runner := Runner { }

start_script:: proc(script: []Event) {
	runner.script = script
runner.state = Continue{}
runner.step = -1
}

draw_level :: proc() {
	draw_map(m)
	for e in entities {
		if !e.disabled {
			draw_entity(e)
		}
	}
}

update_level :: proc(dt: f32) {
	for &e in entities {
		update_entity(dt, &e)
	}
}

set_entity_busy :: proc(e_id: Id, busy: bool) {
	for &e in entities {
		if e.id == e_id {
			e.busy = busy
			fmt.println("set entity busy", e.n, e.busy)
			return
		}
	}
	fmt.println("didn't find entity with id", e_id)
}

set_entity_script :: proc(e_id: Id, script: []Event) {
	for &e in entities {
		if e.id == e_id {
			e.script = script
		}
	}
}

set_entity_state :: proc(e_id: Id, state: State) {
	for &e in entities {
		if e.id == e_id {
			e.state = state
		}
	}
}
