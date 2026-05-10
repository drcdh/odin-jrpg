package game

import "core:strings"
import rl "vendor:raylib"

dialogue_speed: f32 = .05 // seconds

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

dialogue_hurry: bool
dialogue_pause: f32
dialogue_state: Dialogue_State

dialogue_start, dialogue_end: int

dialogue_builder: strings.Builder
dialogue_icon: Animation

init_dialogue :: proc() {
	dialogue_icon = animation_create(.Dialogue_Icon_Small)
}

draw_dialogue :: proc() {
	if _, hidden := dialogue_state.(Dialogue_Hidden); !hidden {
		str := strings.to_string(dialogue_builder)
		if substr, ok := strings.substring_to(str, dialogue_end); ok {
			cstr := strings.clone_to_cstring(substr, context.temp_allocator)
			draw_menu(0, 0, VIEW_TILES_W, 3)
			rl.DrawTextEx(font, cstr, {tile_size / 2, tile_size / 2}, 32, 0, rl.WHITE)
		}
		if _, waiting := dialogue_state.(Dialogue_Wait); waiting {
			draw_animation(dialogue_icon, {view_dim.x - tile_size, 2 * tile_size}, rl.WHITE)
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
		animation_update(&dialogue_icon, rl.GetFrameTime())
		if get_input(.ENTER) {
			dialogue_state = Dialogue_Done{}
		}
	case Dialogue_Done:
	// do nothing. Wait for script runner
	}
}

advance_marquee :: proc() -> bool {
	dialogue_end += 1
	return dialogue_end == strings.builder_len(dialogue_builder)
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

queue_dialogue :: proc(text: string, hurry: bool, pause: f32) {
	ftext, _ := strings.replace(text, "$player", game_data.protagonist_name, -1, context.temp_allocator)
	strings.write_string(&dialogue_builder, ftext)
	dialogue_hurry = hurry
	dialogue_pause = pause
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
	} else if dialogue_hurry {
		dialogue_state = Dialogue_Done{}
	} else {
		dialogue_state = Dialogue_Wait{}
	}
}

tear_down_dialogue :: proc() {
	strings.builder_destroy(&dialogue_builder)
}
