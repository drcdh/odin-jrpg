package game

import rl "vendor:raylib"

THROTTLED_FPS :: 60
throttle := true
zoom: f32 = 1

view_dim: Pixel_Dim
view_origin: Pixel_Coord
view_bottomleft: Pixel_Coord

window_w: i32
window_h: i32

running: bool
quitting: bool // todo: transitions

CURTAIN_TIME :: .5 // seconds
curtain_up: bool
curtain_t: f32 = -1

init_rl :: proc(z: i32 = 4) {
	set_window_mode(z)

	rl.InitWindow(window_w, window_h, "JRPG")
	rl.InitAudioDevice()
	if throttle {
		rl.SetTargetFPS(THROTTLED_FPS)
	}

	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)

	font = load_atlased_font()
}

init :: proc() {
	init_rl()
	initialize_input()
	init_dialogue()
	init_world_menu()

	init_new_game()
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

	draw_transition()

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

	if rl.IsKeyPressed(.F6) {
		rl.ToggleFullscreen()
	}

	update_transition()

	update_debug()

	free_all(context.temp_allocator)
	running = !(quitting || rl.IsKeyDown(.Q))
}

draw_transition :: proc() {
	if curtain_t > 0 {
		ease := curtain_t / CURTAIN_TIME
		if !curtain_up {ease = 1 - ease}
		w := i32(ease * view_dim.x)
		h := i32(ease * view_dim.y)
		x0 := i32(view_dim.x / 2) - w / 2
		y0 := i32(view_dim.y / 2) - h / 2
		rl.DrawRectangle(x0, y0, w, h, rl.BLACK)
	} else if !curtain_up {
		w := i32(view_dim.x)
		h := i32(view_dim.y)
		rl.DrawRectangle(0, 0, w, h, rl.BLACK)
	}
}

update_transition :: proc() {
	if curtain_t > 0 {
		curtain_t -= rl.GetFrameTime()
	}
}

tear_down :: proc() {
	battle_destroy()
	delete_atlased_font(font)
	delete_input()
	tear_down_dialogue()
	unload_sounds()
	tear_down_rl()
}

tear_down_rl :: proc() {
	rl.UnloadRenderTexture(map_rt)
	rl.UnloadTexture(atlas)
	rl.CloseAudioDevice()
	rl.CloseWindow()
}

set_window_mode :: proc(z: i32) {
	zoom = f32(z)
	window_w = VIEW_TILES_W * TILE_SIZE * z
	window_h = VIEW_TILES_H * TILE_SIZE * z
	view_origin.x = 0
	view_origin.y = 0
	tile_size = f32(zoom * TILE_SIZE)
	tile_dim = {tile_size, tile_size}
	view_dim = {tile_size * VIEW_TILES_W, tile_size * VIEW_TILES_H}
	view_bottomleft = view_origin + {0, view_dim.y}
}
