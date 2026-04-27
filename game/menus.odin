package game

import "core:fmt"
import rl "vendor:raylib"

Menu_Closed :: struct {}
// Menu_Closing :: struct { t: f32 }
Menu_Open :: struct {}

Menu_State :: union {
	Menu_Closed,
	// Menu_Closing,
	Menu_Open,
}

menu_0_forget := false
menu_0_selection := 0
menu_0_state : Menu_State
menu_0_options := [?]cstring{
	"More",
	"Fight!",
	"Quit",
}
menu_0_proc :: proc() {
	switch menu_0_selection {
	case 0:
		menu_1_state = Menu_Open{}
	case 1:
		menu_0_state = Menu_Closed{}
		if menu_0_forget {menu_0_selection = 0}
		start_encounter_0()
	case 2:
		menu_0_state = Menu_Closed{}
		quitting = true//Quitting_State{.5}
	}
}

menu_1_forget := false
menu_1_selection := 0
menu_1_state : Menu_State
menu_1_options := [?]cstring{
	"HP +9",
	"Back",
}
menu_1_proc :: proc() {
	switch menu_1_selection {
	case 0:
		PROTAGONIST.stats.hitpoints += 9
	case 1:
		menu_1_state = Menu_Closed{}
		if menu_1_forget {menu_1_selection = 0}
	}
}

draw_menus :: proc() {
	switch s in menu_0_state {
	case Menu_Closed:
	case Menu_Open:
		rl.DrawRectangleV(Pixel_Coord{100, 100}, Pixel_Dim{300, 300}, TEXT_DISPLAY_BACKGROUND)
		for opt, i in menu_0_options {
			tc := TEXT_COLOR
			if i == menu_0_selection {
				tc = rl.Color{50, 100, 100, 255}
			}
			rl.DrawText(opt, 120, i32(100 + i*50), 18, tc)
		}
	}

	switch s in menu_1_state {
	case Menu_Closed:
	case Menu_Open:
		rl.DrawRectangleV(Pixel_Coord{500, 100}, Pixel_Dim{200, 200}, TEXT_DISPLAY_BACKGROUND)
		for opt, i in menu_1_options {
			tc := TEXT_COLOR
			if i == menu_1_selection {
				tc = rl.Color{50, 100, 100, 255}
			}
			rl.DrawText(opt, 520, i32(100 + i*50), 18, tc)
		}
	}
}

update_menus :: proc(dt: f32) {
	switch s in menu_0_state {
	case Menu_Closed:
	//if protag not busy
	if get_input(.MENU) {
		menu_0_state = Menu_Open{}
	}
case Menu_Open:
	if get_input(.MENU) {
	menu_0_state = Menu_Closed{}
		if menu_0_forget {menu_0_selection = 0}
	} else if get_input(.ENTER) {
		menu_0_proc()
	}
}

	switch _ in menu_1_state {
	case Menu_Closed:
	case Menu_Open:
		if get_input(.MENU) {
	menu_1_state = Menu_Closed{}
		if menu_1_forget {menu_1_selection = 0}
	} else if get_input(.ENTER) {
		menu_1_proc()
	}
}
}
