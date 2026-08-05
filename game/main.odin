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

paused: bool
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
	init_darkness()
}

init :: proc() {
	init_rl()
	initialize_input()
	init_dialogue()
	init_ui_icons()
	battle_menu_load()
	shop_load()
	start_menu_load()
	world_menu_load()

	music_init(&music_state)

	start_menu_enter()

	running = true
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	if start_menu_active() {
		start_menu_draw()
	} else if battle.active {
		draw_battle()
	} else if world_menu_active() {
		world_menu_draw()
	} else if shop_menu_active() {
		shop_draw()
	} else {
		draw_world()
	}

	draw_dialogue()

	draw_transition()

	if paused {
		rl.BeginBlendMode(.MULTIPLIED)
		rl.DrawRectangleV({}, view_dim, {80, 80, 155, 255})
		rl.EndBlendMode()
		draw_text(7, 7, "Paused")
	}
	draw_debug()

	rl.EndDrawing()
}

update :: proc() {
	dt := rl.GetFrameTime()

	update_input_state(dt)

	if !paused {
		update_dialogue()
		update_runners(dt)

		if start_menu_active() {
			start_menu_update()
		} else if battle.active {
			update_battle(dt)
		} else if world_menu_active() {
			world_menu_update()
		} else if shop_menu_active() {
			shop_update()
		} else {
			update_world(dt)
			if !pc_busy() && get_input(.MENU) {
				world_menu_enter()
			}
		}
		update_transition()
		update_ui_icons(dt)
	}

	if get_input(.PAUSE) {
		paused = !paused
	}

	if rl.IsKeyPressed(.F6) {
		rl.ToggleFullscreen()
	}

	update_debug()

	free_all(context.temp_allocator)
	running = !(quitting || rl.IsKeyDown(.Q))

	frame_count += 1
	frame_count %= FRAME_COUNT_MAX
}

tear_down :: proc() {
	battle_destroy()
	delete_atlased_font(font)
	delete_darkness()
	delete_input()
	delete_inventory_order()
	delete_runners()
	delete_world_entities()
	tear_down_dialogue()
	battle_menu_unload()
	start_menu_unload()
	world_menu_unload()
	music_shutdown(&music_state)
	unload_sounds()
	shop_unload()
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
	tile_size_int = int(zoom * TILE_SIZE)
	tile_dim = {tile_size, tile_size}
	view_dim = {tile_size * VIEW_TILES_W, tile_size * VIEW_TILES_H}
	view_bottomleft = view_origin + {0, view_dim.y}
}
