package game

import rl "vendor:raylib"

WORLD_WIDTH :: 32
WORLD_HEIGHT :: 28

SCALE :: 2

WINDOW_WIDTH :: TILE_SIZE * WORLD_WIDTH
WINDOW_HEIGHT :: TILE_SIZE * WORLD_HEIGHT

ATLAS_DATA :: #load("atlas.png")

running: bool
quitting := false // todo: transitions

init :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "JRPG")
	rl.InitAudioDevice()

	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)

	font = load_atlased_font()

	initialize_input()
	init_dialogue()
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

	draw_debug()

	rl.EndDrawing()
}

update :: proc() {
	dt := rl.GetFrameTime()

	update_input_state(dt)

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

	update_debug()

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
