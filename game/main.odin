package game

import rl "vendor:raylib"

WORLD_WIDTH :: 32
WORLD_HEIGHT :: 28

SCALE :: 2

WINDOW_WIDTH :: cast(i32)(TILE_SIZE * WORLD_WIDTH)
WINDOW_HEIGHT :: cast(i32)(TILE_SIZE * WORLD_HEIGHT)

ATLAS_DATA :: #load("atlas.png")

running: bool
text_test: bool
quitting := false // todo: transitions

init :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "JRPG")
	rl.InitAudioDevice()

	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)

	font = load_atlased_font()

	initialize_input()
	init_world_menu()

	menu_0_state = Menu_Closed{}
	menu_1_state = Menu_Closed{}

	start_level(.LEVEL_0)

	running = true
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	if battle_active {
		draw_battle()
	} else if world_menu_active {
		draw_world_menu()
	} else {
		draw_world()
		draw_dialogue()
		// draw_menus()
	}

	if text_test {
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, 0}, 16, 0, rl.WHITE)
		rl.DrawLine(0, 16, WINDOW_WIDTH, 16, rl.WHITE)
		rl.DrawTextEx(font, LETTERS_IN_FONT, {0, 16}, 32, 0, rl.WHITE)
		rl.DrawLine(0, 16 + 32, WINDOW_WIDTH, 16 + 32, rl.WHITE)
	}

	rl.EndDrawing()
}

update :: proc() {
	dt := rl.GetFrameTime()

	update_input_state(dt)

	if rl.IsKeyPressed(.T) {text_test = !text_test}

	if battle_active {
		update_battle(dt)
	} else {
		if get_input(.MENU) {
			world_menu_active = !world_menu_active
		}

		if world_menu_active {
			update_world_menu()
		} else {
			// text gets input priority
			update_runner(dt)
			update_world(dt)
			// update_menus(dt)
			update_dialogue()
		}
	}

	free_all(context.temp_allocator)
	running = !(quitting || rl.IsKeyDown(.Q))
}

tear_down :: proc() {
	delete_atlased_font(font)
	delete_input()
	unload_sounds()

	rl.UnloadTexture(atlas)
	rl.CloseAudioDevice()
	rl.CloseWindow()
}
