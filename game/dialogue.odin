package game

import "core:strings"
import rl "vendor:raylib"

dialogue_show := false
dialogue_str: string

draw_dialogue :: proc() {
	if dialogue_show {
		c_str := strings.clone_to_cstring(dialogue_str, context.temp_allocator)
		draw_menu({10, 10, 300, 100})
		rl.DrawTextEx(font, c_str, {20, 20}, 18, 0, TEXT_COLOR)
	}
}
