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

frame_count: int
FRAME_COUNT_MAX :: 10000

music_state: Music_State

init_rl :: proc(z: i32 = 4) {
	set_window_mode(z)

	rl.InitWindow(window_w, window_h, "JRPG")
	rl.InitAudioDevice()
	if throttle {
		rl.SetTargetFPS(THROTTLED_FPS)
	}

	init_atlases()
	init_overlays()
}

init :: proc() {
	init_rl()
	initialize_input()
	init_dialogue()
	init_world_menu()

	music_init(&music_state)

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
	}

	draw_dialogue()

	draw_transition()

	draw_debug()

	rl.EndDrawing()
}

update :: proc() {
	dt := rl.GetFrameTime()

	update_input_state(dt)

	update_dialogue()
	update_runner(dt)

	if battle_active {
		update_battle(dt)
	} else if world_menu_active {
		update_world_menu()
	} else {
		update_world(dt)
		if !pc_busy() && get_input(.MENU) {
			world_menu_active = true
		}
	}

	if rl.IsKeyPressed(.F6) {
		rl.ToggleFullscreen()
	}

	update_transition()

	update_debug()

	free_all(context.temp_allocator)
	running = !(quitting || rl.IsKeyDown(.Q))

	frame_count += 1
	frame_count %= FRAME_COUNT_MAX
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
