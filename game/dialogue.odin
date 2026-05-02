package game

import "core:strings"
import rl "vendor:raylib"

dialogue_speed: f32 = .1 // seconds

Dialogue_Hidden :: struct {}
Dialogue_Marquee :: struct {
	t: f32,
}
Dialogue_Pause :: struct {
	t: f32,
}
Dialogue_Wait :: struct {}
Dialogue_Done :: struct {}

Dialogue_State :: union #no_nil {
	Dialogue_Hidden,
	Dialogue_Marquee,
	Dialogue_Pause,
	Dialogue_Wait,
	Dialogue_Done,
}

// dialogue_buffer : string
dialogue_hurry: bool
dialogue_pause: f32
dialogue_state: Dialogue_State

dialogue_start, dialogue_end: int

dialogue_builder: strings.Builder

draw_dialogue :: proc() {
	if _, hidden := dialogue_state.(Dialogue_Hidden); !hidden {
		str := strings.to_string(dialogue_builder)
		if substr, ok := strings.substring_to(str, dialogue_end); ok {
			cstr := strings.clone_to_cstring(substr, context.temp_allocator)
			draw_menu({TILE_SIZE / 2, TILE_SIZE / 2, f32(WINDOW_WIDTH) - TILE_SIZE, 4 * TILE_SIZE})
			rl.DrawTextEx(font, cstr, {TILE_SIZE, TILE_SIZE}, 32, 0, rl.WHITE)
		}
	}
}

update_dialogue :: proc() {
	dt := rl.GetFrameTime()
	switch &s in dialogue_state {
	case Dialogue_Hidden:
	case Dialogue_Marquee:
		s.t -= dt
		if s.t <= 0 {
			if done := advance_marquee(); done {
				set_next_dialogue_state()
			} else {
				dialogue_state = Dialogue_Marquee {
					t = dialogue_speed,
				}
			}
		}
	case Dialogue_Pause:
		s.t -= dt
		if s.t <= 0 {
			set_next_dialogue_state()
		}
	case Dialogue_Wait:
		if get_input(.ENTER) {
			dialogue_state = Dialogue_Done{}
		}
	case Dialogue_Done:
	// do nothing. Wait for script runner
	}
}

advance_marquee :: proc() -> bool {
	dialogue_end += 1
	return dialogue_end == strings.builder_len(dialogue_builder) - 1
}

clear_dialogue :: proc() {
	strings.builder_reset(&dialogue_builder)
	dialogue_start = 0
	dialogue_end = 0
}

close_dialogue :: proc() {
	clear_dialogue()
	dialogue_state = Dialogue_Hidden{}
}

dialogue_done :: proc() -> bool {
	_, done := dialogue_state.(Dialogue_Done)
	return done
}

queue_dialogue :: proc(text: string) {
	strings.write_string(&dialogue_builder, text)
	dialogue_state = Dialogue_Marquee {
		t = dialogue_speed,
	}
}

set_next_dialogue_state :: proc() {
	if dialogue_pause > 0 {
		dialogue_state = Dialogue_Pause {
			t = dialogue_pause,
		}
		dialogue_pause = 0
	} else if !dialogue_hurry {
		dialogue_state = Dialogue_Wait{}
	}
}
