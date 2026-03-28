package game

import "core:fmt"

import la "core:math/linalg"

import rl "vendor:raylib"

Pixel :: f32
Pixel_Coord :: [2]Pixel
Pixel_Dim :: [2]Pixel

PIXEL_ORIGIN: Pixel_Coord

Tile_T :: int
Tile_Coord :: [2]Tile_T
Tile_Offset :: Pixel_Coord

TILE_SIZE: Pixel : 32
TILE_DIM :: Pixel_Dim{TILE_SIZE, TILE_SIZE}

WINDOW_WIDTH: i32 : cast(i32)(TILE_SIZE) * 30
WINDOW_HEIGHT: i32 : cast(i32)(TILE_SIZE) * 30

PLAYER_COLOR :: rl.Color{200, 120, 120, 255}

entities: [dynamic]Entity
m: Map
prev_input: Tile_Coord

draw_level :: proc() {
	// fmt.println("draw_level")
	draw_map(m)
	for e in entities {
		draw_entity(e)
	}
}

update_level :: proc(dt: f32) {
	// fmt.println("update_level")
	for &e in entities {
		update_entity(dt, &e)
	}
}

start :: proc(args: []string) -> int {
	fmt.println("Hellope! Environment: ", #config(env, "dev"))

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "JRPG")

	start_level()

	fmt.println("Starting window_loop")

	window_loop: for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw_level()
		rl.EndDrawing()

		dt := rl.GetFrameTime()

		if rl.IsKeyDown(.Q) {
			break window_loop
		}

		update_level(dt)
	}

	rl.CloseWindow()

	return 0
}
