package game

import "core:fmt"
import "core:strings"
import "core:time"

import rl "vendor:raylib"

WINDOW_WIDTH: i32 : cast(i32)(TILE_SIZE) * 30
WINDOW_HEIGHT: i32 : cast(i32)(TILE_SIZE) * 30

frame_num := 1

dialogue_show := false
dialogue_str : string
draw_dialogue :: proc() {
	if dialogue_show {
		c_str := strings.clone_to_cstring(dialogue_str)
	rl.DrawRectangleV(Pixel_Coord{10, 10}, Pixel_Dim{300, 100}, TEXT_DISPLAY_BACKGROUND)
	rl.DrawText(c_str, 20, 20, 18, TEXT_COLOR)
	}
}

start :: proc(args: []string) -> int {
	fmt.println("Hellope! Environment: ", #config(env, "dev"))

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "JRPG")

	start_level()

	fmt.println("Starting window_loop")

	window_loop: for !rl.WindowShouldClose() {
		// fmt.println("FRAME", frame_num)
		// frame_num += 1

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw_level()
		// draw_text() // text gets drawn on top
		draw_dialogue()
		rl.EndDrawing()

		if rl.IsKeyDown(.Q) {
			break window_loop
		}

		capture_input()

		dt := rl.GetFrameTime()

	 // text gets input priority
		update_runner(dt)
		// update_text(dt)
		update_level(dt)
		// time.sleep(time.Second)
	}

	rl.CloseWindow()

	return 0
}
