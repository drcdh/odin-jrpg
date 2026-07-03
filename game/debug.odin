package game

import "core:fmt"
import rl "vendor:raylib"

DEBUG_FRAMERATE_PERIOD :: 15 // seconds

debug_framerate: bool
debug_framerate_count: int
debug_framerate_sum: f32

debug_grid: bool
debug_text: bool

draw_debug :: proc() {
	if debug_framerate {
		h: f32 = 20
		origin := Pixel_Coord{0, view_dim.y - h}
		rl.DrawRectangleV(origin, {view_dim.x, h}, rl.BLACK)
		mean: f32 = 0
		if debug_framerate_sum > 0 {
			mean = f32(debug_framerate_count) / debug_framerate_sum
		}
		rl.DrawTextEx(
			font,
			fmt.caprintf("%f seconds | %d frames | %f fps", debug_framerate_sum, debug_framerate_count, mean),
			origin,
			h,
			0,
			rl.WHITE,
		)
	}

	if debug_grid {
		c := rl.Color{100, 50, 50, 200}
		dg := i32(tile_size)
		G := i32(view_dim.x)
		t := 0
		for g: i32 = 0; g <= G; g += dg {
			x := i32(view_dim.x)
			y := i32(view_dim.y)
			rl.DrawLine(g, 0, g, y, c)
			rl.DrawLine(0, g, x, g, c)
			rl.DrawTextEx(font, fmt.caprintf("%X", t), {0, f32(g)}, tile_size, 0, c)
			rl.DrawTextEx(font, fmt.caprintf("%X", t), {f32(g), 0}, tile_size, 0, c)
			t += 1
		}
	}

	if debug_text {
		h0 := tile_size
		h := h0
		rl.DrawLineV({0, h0}, {view_dim.x, h0}, rl.WHITE)
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, 0}, h0, 0, rl.WHITE)
		h1 := tile_size / 2
		h += h1
		rl.DrawLineV({0, h}, {view_dim.x, h}, rl.WHITE)
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, h - h1}, h1, 0, rl.WHITE)
		h2 := tile_size / 4
		h += h2
		rl.DrawLineV({0, h}, {view_dim.x, h}, rl.WHITE)
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, h - h2}, h2, 0, rl.WHITE)
	}

}

update_debug :: proc() {
	if rl.IsKeyPressed(.B) { fmt.printfln("%#v", battle) }
	if rl.IsKeyPressed(.F) {debug_framerate = !debug_framerate}
	if rl.IsKeyPressed(.G) {debug_grid = !debug_grid}
	if rl.IsKeyPressed(.T) {debug_text = !debug_text}

	if rl.IsKeyPressed(.GRAVE) {
		throttle = !throttle
		if throttle {
			rl.SetTargetFPS(THROTTLED_FPS)
		} else {
			rl.SetTargetFPS(5000)
		}
		fmt.println("FPS throttling", throttle)
	}

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
