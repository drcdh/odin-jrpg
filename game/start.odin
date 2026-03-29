package game

import "core:fmt"

import rl "vendor:raylib"

WINDOW_WIDTH: i32 : cast(i32)(TILE_SIZE) * 30
WINDOW_HEIGHT: i32 : cast(i32)(TILE_SIZE) * 30

start :: proc(args: []string) -> int {
	fmt.println("Hellope! Environment: ", #config(env, "dev"))

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "JRPG")

	start_level()

	fmt.println("Starting window_loop")

	window_loop: for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw_level()
		draw_text()
		rl.EndDrawing()

		dt := rl.GetFrameTime()

		if rl.IsKeyDown(.Q) {
			break window_loop
		}

		update_level(dt)
		update_text(dt)
	}

	rl.CloseWindow()

	return 0
}
