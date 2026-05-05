package game

import "core:fmt"
import rl "vendor:raylib"

DEBUG_FRAMERATE_HEIGHT :: 32
DEBUG_FRAMERATE_ORIGIN :: Pixel_Coord{0, WINDOW_HEIGHT - DEBUG_FRAMERATE_HEIGHT}
DEBUG_FRAMERATE_PERIOD :: 60 // seconds
debug_framerate: bool
debug_framerate_count: int
debug_framerate_sum: f32

debug_grid: bool
debug_text: bool

draw_debug :: proc() {
	if debug_framerate {
		rl.DrawRectangleV(DEBUG_FRAMERATE_ORIGIN, {WINDOW_WIDTH, TILE_SIZE}, rl.BLACK)
		mean: f32 = 0
		if debug_framerate_sum > 0 {
			mean = f32(debug_framerate_count) / debug_framerate_sum
		}
		rl.DrawTextEx(
			font,
			fmt.caprintf("%f seconds | %d frames | %f fps", debug_framerate_sum, debug_framerate_count, mean),
			DEBUG_FRAMERATE_ORIGIN,
			DEBUG_FRAMERATE_HEIGHT,
			0,
			rl.WHITE,
		)
	}

	if debug_grid {
		for g: i32 = 0; g <= WINDOW_WIDTH; g += TILE_SIZE * WORLD_ZOOM {
			rl.DrawLine(g, 0, g, WINDOW_HEIGHT, {100, 50, 50, 200})
			rl.DrawLine(0, g, WINDOW_WIDTH, g, {100, 50, 50, 200})
		}
	}

	if debug_text {
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, 0}, 16, 0, rl.WHITE)
		rl.DrawLine(0, 16, WINDOW_WIDTH, 16, rl.WHITE)
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, 16}, 32, 0, rl.WHITE)
		rl.DrawLine(0, 16 + 32, WINDOW_WIDTH, 16 + 32, rl.WHITE)
	}

}

update_debug :: proc() {
	if rl.IsKeyPressed(.F) {debug_framerate = !debug_framerate}
	if rl.IsKeyPressed(.G) {debug_grid = !debug_grid}
	if rl.IsKeyPressed(.T) {debug_text = !debug_text}

	if debug_framerate {
		dt := rl.GetFrameTime()
		if debug_framerate_sum >= DEBUG_FRAMERATE_PERIOD {
			debug_framerate_count = 1
			debug_framerate_sum = dt
		} else {
			debug_framerate_count += 1
			debug_framerate_sum += dt
		}
	}
}
