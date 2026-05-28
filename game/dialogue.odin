package game

import "core:fmt"
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

dialogue_buffer_start, dialogue_buffer_end: int
dialogue_marquee_start, dialogue_marquee_end: int

dialogue_builder: strings.Builder
dialogue_marquee: strings.Builder
dialogue_icon: Animation

dialogue_lines: int = 4 // todo
dialogue_line_width: int = 2 * VIEW_TILES_W - 2

init_dialogue :: proc() {
	dialogue_icon = animation_create(.Dialogue_Icon_Small)
}

draw_dialogue :: proc() {
	// rl.DrawText(fmt.caprint(dialogue_state, allocator = context.temp_allocator), i32(6*tile_size), i32(12 * tile_size), 24, rl.BLACK) // debug
	if _, hidden := dialogue_state.(Dialogue_Hidden); !hidden {
		str := strings.to_string(dialogue_marquee)
		if substr, ok := strings.substring_to(str, dialogue_marquee_end); ok {
			draw_menu(0, 0, VIEW_TILES_W, (dialogue_lines + 2) / 2)
			draw_text(.5, .5, strings.clone_to_cstring(substr, context.temp_allocator))
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
			if dialogue_buffer_end < strings.builder_len(dialogue_builder) {
				refill_marquee()
				dialogue_state = Dialogue_Marquee{}
			} else {
				dialogue_state = Dialogue_Done{}
			}
		}
	case Dialogue_Done:
	// do nothing. Wait for script runner
	}
}

advance_marquee :: proc() -> bool {
	dialogue_marquee_end += 1
	return dialogue_marquee_end == strings.builder_len(dialogue_marquee)
}

refill_marquee :: proc() {
	fmt.println("\nREFILLING MARQUEE")
	strings.builder_reset(&dialogue_marquee)
	refill_start := dialogue_buffer_end
	buffer := strings.to_string(dialogue_builder)
	for l in 1 ..= dialogue_lines {
		fmt.printf(
			"line %d/%d: refill_start = %d; buffer len = %d\n",
			l,
			dialogue_lines,
			refill_start,
			strings.builder_len(dialogue_builder),
		)
		if refill_start >= strings.builder_len(dialogue_builder) {
			break
		}
		next_newline: int
		next_line: string
		if max_substr, part := strings.substring(buffer, refill_start, dialogue_line_width + refill_start); part {
			fmt.printf("looking for space or newline in substring %q\n", max_substr)
			next_newline = strings.index(max_substr, "\n")
			if next_newline < 0 {
				next_newline = strings.last_index(max_substr, " ")
			}
			fmt.printf(
				"next_newline in [%d, %d) = %d\n",
				refill_start,
				dialogue_line_width + refill_start,
				next_newline + refill_start,
			)
			fmt.printf("next_newline in [%d, %d) = %d\n", 0, dialogue_line_width, next_newline)
			next_line, _ = strings.substring_to(max_substr, next_newline)
		} else {
			fmt.printf("looking for newline (not space) in remainder %q\n", max_substr)
			next_newline = strings.index(max_substr, "\n")
			if next_newline < 0 {
				next_newline = strings.builder_len(dialogue_builder)
			}
			fmt.printf(
				"next_newline in [%d, %d) = %d\n",
				refill_start,
				dialogue_line_width + refill_start,
				next_newline + refill_start,
			)
			fmt.printf("next_newline in [%d, %d) = %d\n", 0, dialogue_line_width, next_newline)
			if next_newline < 0 {
				// next_line, _ = strings.substring_from(buffer, refill_start)
				next_line = max_substr
			} else {
				next_line, _ = strings.substring_to(max_substr, next_newline)
			}
		}
		fmt.printf("appending line to marquee '%s'\n", next_line)
		strings.write_string(&dialogue_marquee, next_line)
		strings.write_string(&dialogue_marquee, "\n")
		refill_start = next_newline + refill_start + 1
	}
	dialogue_buffer_end = refill_start
	dialogue_marquee_start = 0
	dialogue_marquee_end = 0
}

clear_dialogue :: proc() {
	strings.builder_reset(&dialogue_builder)
	strings.builder_reset(&dialogue_marquee)
	dialogue_buffer_start = 0
	dialogue_buffer_end = 0
	dialogue_marquee_start = 0
	dialogue_marquee_end = 0
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
	refill_marquee()
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
	strings.builder_destroy(&dialogue_marquee)
}
