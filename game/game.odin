package game

import "core:fmt"

entities: [dynamic]Entity
m: Map
runner := Runner{}

quitting := false // todo: transitions

get_entity_at_tile :: proc(t: Tile_Coord) -> Maybe(int) {
	for e, i in entities {
		if e.k.tile == t {
			return i
		}
	}
	return nil
}

activate_entity_idx :: proc(i: int) {
	start_script(entities[i].script)
}

start_script :: proc(script: []Event) {
	if script != nil {
		fmt.println("starting script of len", len(script))
		runner.script = script
		runner.state = Continue{}
		runner.step = -1
	}
}

start_entity_script :: proc(id: Id) {
	for e in entities {
		if e.id == id {
			if e.script != nil {
				fmt.println("starting entity script", e.n)
				start_script(e.script)
			} else {
				fmt.println("not starting nil entity script", e.n)
			}
		}
	}
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
			fmt.println("set entity with script of len", e.n, len(e.script))
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
