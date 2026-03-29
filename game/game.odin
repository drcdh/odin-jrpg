package game

import "core:fmt"

import rl "vendor:raylib"

entities: [dynamic]Entity
m: Map
text: [dynamic]Text_Display

draw_level :: proc() {
	draw_map(m)
	for e in entities {
		if !e.disabled {
			draw_entity(e)
		}
	}
}

draw_text :: proc() {
	for t in text {
		if !t.disabled {
			draw_text_display(t)
		}
	}
}

update_level :: proc(dt: f32) {
	for &e in entities {
		update_entity(dt, &e)
	}
}

update_text :: proc(dt: f32) {
	for &t in text {
		if !t.disabled {
			t.time += dt
			t.time += dt
			if t.time >= t.pause {
				if !t.wait || rl.IsKeyDown(.SPACE) {
					t.disabled = true
					t.on_end(t.selection)
				}
			}

		}
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
