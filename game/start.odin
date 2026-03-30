package game

import "core:fmt"

import rl "vendor:raylib"

WINDOW_WIDTH: i32 : cast(i32)(TILE_SIZE) * 30
WINDOW_HEIGHT: i32 : cast(i32)(TILE_SIZE) * 30

frame_num := 1

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
		draw_text() // text gets drawn on top
		rl.EndDrawing()

		if rl.IsKeyDown(.Q) {
			break window_loop
		}

		capture_input()

		dt := rl.GetFrameTime()

		update_text(dt) // text gets input priority
		update_level(dt)
	}

	rl.CloseWindow()

	return 0
}
