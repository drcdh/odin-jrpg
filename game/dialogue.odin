package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

dialogue_speed: f32 = .05 // seconds

Dialogue_Choose :: struct {}
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
	Dialogue_Choose,
	Dialogue_Done,
}

DEFAULT_DIALOGUE_LINES :: 4
MAX_DIALOGUE_LINES :: 10

dialogue_hurry: bool
dialogue_pause: f32
dialogue_state: Dialogue_State

dialogue_buffer_start, dialogue_buffer_end: int
dialogue_marquee_line: int
dialogue_marquee_start, dialogue_marquee_end: int

dialogue_builder: strings.Builder
dialogue_marquee_lines: [MAX_DIALOGUE_LINES]strings.Builder
dialogue_icon: Animation

dialogue_lines: int = DEFAULT_DIALOGUE_LINES
dialogue_line_width: int = 2 * VIEW_TILES_W - 2

dialogue_choices: [dynamic]string
dialogue_choice_made: Maybe(int)
dialogue_choice_pending: int

init_dialogue :: proc() {
	dialogue_icon = animation_create(.Dialogue_Icon_Small)
}

draw_dialogue :: proc() {
	// rl.DrawText( fmt.ctprint(dialogue_state), i32(6 * tile_size), i32(12 * tile_size), 24, rl.BLACK,) // debug
	if _, hidden := dialogue_state.(Dialogue_Hidden); !hidden {
		draw_pane(0, 0, VIEW_TILES_W, (dialogue_lines + 2) / 2)
		for l in 0 ..< dialogue_marquee_line {
			// draw completed lines
			// fmt.printfln("% 4d: draw completed line %d/%d", frame_count, l+1, dialogue_lines)
			str := strings.to_string(dialogue_marquee_lines[l])
			draw_text(.5, f32(l + 1) / 2, strings.clone_to_cstring(str, context.temp_allocator))
		}
		{
			// draw line being written to
			// fmt.printfln("% 4d: draw current line %d/%d up to %d", frame_count, dialogue_marquee_line+1, dialogue_lines, dialogue_marquee_end)
			str := strings.to_string(dialogue_marquee_lines[dialogue_marquee_line])
			if substr, ok := strings.substring_to(str, dialogue_marquee_end); ok {
				draw_text(.5, f32(dialogue_marquee_line + 1) / 2, strings.clone_to_cstring(substr, context.temp_allocator))
			}
		}
		if _, waiting := dialogue_state.(Dialogue_Wait); waiting {
			draw_animation(dialogue_icon, {view_dim.x - tile_size, f32(dialogue_lines / 2) * tile_size}, rl.WHITE)
		}
		if _, choosing := dialogue_state.(Dialogue_Choose); choosing {
			draw_choices()
		}
	}
}

draw_choices :: proc() {
	if len(dialogue_choices) > 0 {
		draw_pane(0, (dialogue_lines + 2) / 2, VIEW_TILES_W, (len(dialogue_choices) + 2) / 2)
		for c, i in dialogue_choices {
			if i == dialogue_choice_pending {
				draw_text(
					.5,
					f32(i + dialogue_lines + 2) / 2 + .5,
					strings.clone_to_cstring(c, context.temp_allocator),
					rl.YELLOW,
				)
			} else {
				draw_text(
					.5,
					f32(i + dialogue_lines + 2) / 2 + .5,
					strings.clone_to_cstring(c, context.temp_allocator),
					rl.GRAY,
				)
			}
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
	case Dialogue_Choose:
		if get_input(.ENTER) {
			dialogue_choice_made = dialogue_choice_pending
			dialogue_choice_pending = 0
			clear(&dialogue_choices)
			dialogue_state = Dialogue_Done{}
		} else if dy, ok := get_y_input().?; ok {
			dialogue_choice_pending += dy
			if dialogue_choice_pending < 0 {
				dialogue_choice_pending = len(dialogue_choices) - 1
			} else if dialogue_choice_pending >= len(dialogue_choices) {
				dialogue_choice_pending = 0
			}
		}
	case Dialogue_Done:
	// do nothing. Wait for script runner
	}
}

advance_marquee :: proc() -> bool {
	m := dialogue_marquee_lines[dialogue_marquee_line] // current marquee
	dialogue_marquee_end += 1
	if dialogue_marquee_end >= strings.builder_len(m) {
		if dialogue_marquee_line == dialogue_lines {return true}
		dialogue_marquee_line += 1
		dialogue_marquee_end = 0
	}
	return false
}

refill_marquee :: proc() {
	fmt.println("\nREFILLING MARQUEE")
	clear_marquee()
	refill_start := dialogue_buffer_end
	buffer := strings.to_string(dialogue_builder)
	for l in 0 ..< dialogue_lines {
		fmt.printf(
			"line %d/%d: refill_start = %d; buffer len = %d\n",
			l + 1,
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
			fmt.printfln("looking for space or newline in substring %q", max_substr)
			next_newline = strings.index(max_substr, "\n")
			if next_newline < 0 {
				next_newline = strings.last_index(max_substr, " ")
			}
			fmt.printfln(
				"next_newline in [%d, %d) = %d",
				refill_start,
				dialogue_line_width + refill_start,
				next_newline + refill_start,
			)
			fmt.printfln("next_newline in [%d, %d) = %d", 0, dialogue_line_width, next_newline)
			next_line, _ = strings.substring_to(max_substr, next_newline)
		} else {
			fmt.printfln("looking for newline (not space) in remainder %q", max_substr)
			next_newline = strings.index(max_substr, "\n")
			if next_newline < 0 {
				next_newline = strings.builder_len(dialogue_builder)
			}
			fmt.printfln(
				"next_newline in [%d, %d) = %d",
				refill_start,
				dialogue_line_width + refill_start,
				next_newline + refill_start,
			)
			fmt.printfln("next_newline in [%d, %d) = %d", 0, dialogue_line_width, next_newline)
			if next_newline < 0 {
				// next_line, _ = strings.substring_from(buffer, refill_start)
				next_line = max_substr
			} else {
				next_line, _ = strings.substring_to(max_substr, next_newline)
			}
		}
		fmt.printfln("appending to line %d/%d of marquee '%s'", l + 1, dialogue_lines, next_line)
		strings.write_string(&dialogue_marquee_lines[l], next_line)
		refill_start = next_newline + refill_start + 1
	}
	dialogue_buffer_end = refill_start
	dialogue_marquee_start = 0
	dialogue_marquee_end = 0
}

clear_dialogue :: proc() {
	strings.builder_reset(&dialogue_builder)
	dialogue_buffer_start = 0
	dialogue_buffer_end = 0
	clear_marquee()
}

clear_marquee :: proc() {
	for &m in dialogue_marquee_lines {
		strings.builder_reset(&m)
	}
	dialogue_marquee_line = 0
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

queue_dialogue :: proc(text: string, hurry := false, pause: f32 = 0) {
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
	for &m in dialogue_marquee_lines {
		strings.builder_destroy(&m)
	}
	clear(&dialogue_choices)
	delete(dialogue_choices)
}
