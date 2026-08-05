package game

import "core:strings"
import rl "vendor:raylib"

Start_Menu_UI_Data :: struct {
	fade_t:    f32,
	start_t:   f32,
	top_idx:   int,
	save_data: [dynamic]string,
	load_sel:  Selection,
}

Start_Menu_UI_State :: enum {
	Inactive,
	Fade_In,
	Start,
	Top,
	Load,
}

Start_Menu_Pane :: enum {
	Top,
	Load,
}

START_MENU_NUM_PANES :: len(Start_Menu_Pane)

Start_Menu :: struct {
	stale:         [START_MENU_NUM_PANES]bool,
	textures:      [START_MENU_NUM_PANES]rl.RenderTexture,
	using ui_data: Start_Menu_UI_Data,
	ui_state:      Start_Menu_UI_State,
}

START_MENU_PANE_ORIGINS := [START_MENU_NUM_PANES]Tile_Coord {
	{6, 10}, // Top
	{4, 2}, // Load
}

START_MENU_PANE_DIM := [START_MENU_NUM_PANES]Tile_Coord {
	{4, 3}, // Top
	{8, START_MENU_LOAD_ROWS + 1}, // Load
}

START_MENU_LOAD_ROWS :: 8

start_menu: Start_Menu

start_menu_load :: proc() {
	for pane in Start_Menu_Pane {
		dim := START_MENU_PANE_DIM[pane]
		start_menu.textures[pane] = rl.LoadRenderTexture(i32(dim.x * tile_size_int), i32(dim.y * tile_size_int))
	}
}

start_menu_unload :: proc() {
	for t in start_menu.textures {
		rl.UnloadRenderTexture(t)
	}
}

start_menu_enter :: proc() {
	start_menu.ui_data = Start_Menu_UI_Data{}
	start_menu.ui_state = .Fade_In
	start_menu_set_stale(.Top)
	start_menu_read_data()
	transition.curtain_up = true
}

start_menu_exit :: proc() {
	start_menu.ui_state = .Inactive
	for s in start_menu.save_data {
		delete(s)
	}
	clear(&start_menu.save_data)
}

start_menu_active :: proc() -> bool {
	return start_menu.ui_state != .Inactive
}

start_menu_set_stale :: proc(pane: Start_Menu_Pane) {
	start_menu.stale[pane] = true
}

start_menu_draw :: proc() {
	for &stale, i in start_menu.stale {
		if stale {
			start_menu_redraw_pane(Start_Menu_Pane(i))
			stale = false
		}
	}

	switch start_menu.ui_state {
	case .Inactive:
	case .Fade_In:
		start_menu_draw_title()
	case .Start:
		start_menu_draw_title()
	case .Top:
		start_menu_draw_title()
		start_menu_draw_panes(.Top)
	case .Load:
		start_menu_draw_panes(.Load)
	}

	switch start_menu.ui_state {
	case .Inactive:
	case .Fade_In:
	case .Start:
	case .Top:
		origin := START_MENU_PANE_ORIGINS[Start_Menu_Pane.Top]
		draw_text_icon(.5, .5 * f32(1 + start_menu.top_idx), origin)
	case .Load:
		origin := START_MENU_PANE_ORIGINS[Start_Menu_Pane.Load]
		draw_text_icon(.5, .5 * (1 + selection_row_f(start_menu.load_sel)), origin)
	}
}

start_menu_redraw_top_pane :: proc() {
	draw_text(1, 0.5, "New")
	draw_text(1, 1.0, "New+", rl.GRAY)
	draw_text(1, 1.5, "Load", rl.GRAY if len(start_menu.save_data) == 0 else rl.WHITE)
	draw_text(1, 2.0, "Quit")
}

start_menu_redraw_load_pane :: proc() {
	for r in 0 ..< START_MENU_LOAD_ROWS {
		if r >= len(start_menu.save_data) {break}
		s := start_menu.save_data[r + start_menu.load_sel.origin_idx]
		draw_text(.5, .5 * f32(1 + r), strings.clone_to_cstring(s, context.temp_allocator))
	}
}

start_menu_redraw_pane :: proc(pane: Start_Menu_Pane) {
	rl.BeginTextureMode(start_menu.textures[pane])
	draw_pane(START_MENU_PANE_DIM[pane])
	switch pane {
	case .Top:
		start_menu_redraw_top_pane()
	case .Load:
		start_menu_redraw_load_pane()
	}
	rl.EndTextureMode()
}

start_menu_draw_pane :: proc(pane: Start_Menu_Pane) {
	origin := tile_to_pixel(START_MENU_PANE_ORIGINS[pane])
	texture := start_menu.textures[pane].texture
	w := f32(texture.width)
	h := f32(texture.height)
	dest := rl.Rectangle{origin.x, origin.y, w, -h}
	rl.DrawTexturePro(texture, {0, 0, w, -h}, dest, {}, 0, rl.WHITE)
}

start_menu_draw_panes :: proc(panes: ..Start_Menu_Pane) {
	for pane in panes {
		start_menu_draw_pane(pane)
	}
}

start_menu_update :: proc() {
	switch start_menu.ui_state {
	case .Inactive:

	case .Fade_In:
		start_menu.fade_t += rl.GetFrameTime()
		if get_input(.ENTER) || get_input(.CANCEL) {
			start_menu.ui_state = .Top
		}

	case .Start:
		if get_input(.ENTER) || get_input(.CANCEL) {
			start_menu.ui_state = .Top
		}

	case .Top:
		if get_input(.ENTER) {
			switch start_menu.top_idx {
			case 0:
				queue_events([]Event{Curtain_Down{}, New_Game{}, End{}})
			case 1:
				play_sound(.Blerp)
			case 2:
				filepath := "save_game.json"
				save_data := read_saved_game_data(filepath)
				queue_events([]Event{Curtain_Down{}, Load_Game{save_data}, End{}})
			// if len(start_menu.save_data) > 0 {
			// 	start_menu.ui_state = .Load
			// } else {
			// 	play_sound(.Blerp)
			// }
			case 3:
				queue_events([]Event{Curtain_Down{}, Quit{}, End{}})
			}
		} else if dy, ok := get_y_input().?; ok {
			start_menu.top_idx += dy
			start_menu.top_idx %%= 4
		}

	case .Load:
		if get_input(.ENTER) {
			filepath := start_menu.save_data[selection_row(start_menu.load_sel)]
			save_data := read_saved_game_data(filepath)
			queue_events([]Event{Curtain_Down{}, Load_Game{save_data}, End{}})
		} else if dy, ok := get_y_input().?; ok {
			start_menu.load_sel = shift_windowed_selection(
				dy,
				start_menu.load_sel,
				START_MENU_LOAD_ROWS,
				len(start_menu.save_data),
			)
			start_menu_set_stale(.Load)
		}
	}
}

start_menu_draw_title :: proc() {
	FADE_IN_T :: 3
	tint := rl.ORANGE
	tint2 := rl.BLUE
	if start_menu.ui_state == .Fade_In {
		if start_menu.fade_t >= FADE_IN_T {
			start_menu.ui_state = .Start
		} else {
			tint.a = u8(255 * start_menu.fade_t / FADE_IN_T)
			tint2.a = u8(255 * start_menu.fade_t / FADE_IN_T)
		}
	}
	rl.DrawTextEx(font, "ODIN JRPG", {1.25 * tile_size, 3 * tile_size}, 1.5 * tile_size, 0, tint)
	rl.DrawTextEx(font, "ODIN JRPG", {1.35 * tile_size, 3.1 * tile_size}, 1.5 * tile_size, 0, tint2)

	if start_menu.ui_state == .Start {
		draw_text(4, 10, "Press Z to Start")
	}
}

start_menu_read_data :: proc() {
	// TODO
}
