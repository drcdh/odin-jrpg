package game

import rl "vendor:raylib"

Text_Exit :: proc(selection: int)

Text_Display :: struct {
	id:         Id,
	disabled:   bool,
	on_end:     Text_Exit,
	pause:      f32,
	selection:  int,
	selections: []cstring,
	text:       cstring,
	time:       f32,
	wait:       bool, // wait for keypress
}

// last_id := -1
//
// new_id :: proc() -> Id {
// 	last_id += 1
// 	return last_id
// }
//
//
// create_text_display :: proc(text: cstring, on_end: Text_Exit, pause: f32, wait: bool) -> Text_Display {
// 	// todo: insert arguments like character name
// 	// todo: option to "render" text once or at draw-time (useful for HUD countdowns)
// 	return Text_Display {
// 		id=new_id(),
// 		pause= pause,
// 		text=text,
// 		time=0,
// 		wait=wait,
// 	}
// }

TEXT_COLOR := rl.Color{50, 10, 10, 255}
TEXT_DISPLAY_BACKGROUND := rl.Color{200, 200, 200, 255}

draw_text_display :: proc(td: Text_Display) {
	rl.DrawRectangleV(
		Pixel_Coord{10, 10},
		Pixel_Dim{300, 100},
		TEXT_DISPLAY_BACKGROUND,
	)
	rl.DrawText(td.text, 20, 20, 18, TEXT_COLOR)
}
