package game

import "core:fmt"
import "core:strings"
import "core:time"

import rl "vendor:raylib"

WINDOW_WIDTH: i32 : cast(i32)(TILE_SIZE) * 30
WINDOW_HEIGHT: i32 : cast(i32)(TILE_SIZE) * 30

ATLAS_DATA :: #load("atlas.png")

TEXT_COLOR := rl.Color{50, 10, 10, 255}
TEXT_DISPLAY_BACKGROUND := rl.Color{200, 200, 200, 255}

dialogue_show := false
dialogue_str: string

draw_dialogue :: proc() {
	if dialogue_show {
		c_str := strings.clone_to_cstring(dialogue_str, context.temp_allocator)
		rl.DrawRectangleV(Pixel_Coord{10, 10}, Pixel_Dim{300, 100}, TEXT_DISPLAY_BACKGROUND)
		rl.DrawTextEx(font, c_str, {20, 20}, 18, 0, TEXT_COLOR)
	}
}

frame_num := 1

start :: proc(args: []string) -> int {
	fmt.println("Hellope! Environment: ", #config(env, "dev"))

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "JRPG")
	rl.InitAudioDevice()

	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)

	font = load_atlased_font()

	initialize_input()

	menu_0_state = Menu_Closed{}
	menu_1_state = Menu_Closed{}

	start_level(.LEVEL_0)

	fmt.println("Starting window_loop")

	window_loop: for !rl.WindowShouldClose() {
		// fmt.println("FRAME", frame_num)
		// frame_num += 1

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		if battle_active {
			draw_battle()
		} else {
			draw_level()
			draw_dialogue()
			draw_menus()
		}
		rl.EndDrawing()

		if quitting || rl.IsKeyDown(.Q) {
			break window_loop
		}

		dt := rl.GetFrameTime()

		update_input_state(dt)

		if battle_active {
			update_battle(dt)
		} else {
			// text gets input priority
			update_runner(dt)
			update_level(dt)
			update_menus(dt)
		}

		free_all(context.temp_allocator)
	}

	free_all(context.temp_allocator)

	delete_atlased_font(font)
	delete_input()
	unload_sounds()

	rl.UnloadTexture(atlas)
	rl.CloseAudioDevice()
	rl.CloseWindow()

	return 0
}
