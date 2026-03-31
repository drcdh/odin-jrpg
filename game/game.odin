package game

import "core:fmt"

entities: [dynamic]Entity
m: Map
// text: [dynamic]Text_Display
text: Text_Display


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

draw_text :: proc() {
	if text.id != 0 {
		// fmt.println("drawing text", text)
		draw_text_display(text)
	}
	// for t in text {
	// 	if !t.disabled {
	// 		draw_text_display(t)
	// 	}
	// }
}

update_level :: proc(dt: f32) {
	for &e in entities {
		update_entity(dt, &e)
	}
}

update_text :: proc(dt: f32) {
	if text.id != 0 {
		text.time += dt
		if text.time >= text.pause {
			if !text.wait || get_input(Game_Input.ENTER) {
				fmt.println("got enter. ending text display", text.id)
				old := text
				text = Text_Display{}
				old.on_end(old.selection)
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
