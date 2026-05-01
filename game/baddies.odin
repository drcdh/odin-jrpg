package game

import "core:fmt"

Baddy_Template :: struct {
	name:  cstring,
	stats: Stats,
	texture: string,
	turn:  Turn_Proc,
}

mouse_sized_rat := Baddy_Template {
	name = "Mouse-Sized Rat",
	stats = Stats{hitpoints = 1, offense = 1, defense = 1},
	texture = "mouse-sized_rat.png",
	turn = ATTACK_RANDOM_OPPONENT,
}

rat_sized_mouse := Baddy_Template {
	name = "Rat-Sized Mouse",
	stats = Stats{hitpoints = 3, offense = 3, defense = 2},
	texture = "rat-sized_mouse.png",
	turn = ATTACK_RANDOM_OPPONENT,
}

Baddy_Id :: enum {
	None,
	Mouse_Sized_Rat,
	Rat_Sized_Mouse,
}

get_baddy_template :: proc(baddy_id: Baddy_Id) -> ^Baddy_Template {
	switch baddy_id {
	case .None:
		return nil
	case .Mouse_Sized_Rat:
		return &mouse_sized_rat
	case .Rat_Sized_Mouse:
		return &rat_sized_mouse
	}
	return nil
}
