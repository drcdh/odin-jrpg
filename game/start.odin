package game

import rl "vendor:raylib"

running : bool

init :: proc() {
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

	running = true
}

draw :: proc() {
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
	}

update :: proc() {

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
		running = !( quitting || rl.IsKeyDown(.Q))
	}

tear_down :: proc() {
	delete_atlased_font(font)
	delete_input()
	unload_sounds()

	rl.UnloadTexture(atlas)
	rl.CloseAudioDevice()
	rl.CloseWindow()
}
