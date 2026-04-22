package game

Combatant :: struct {
	character: Character,
	enabled:   bool,
	t:         int,
	team:      int,
	turn:      Turn_Proc,
}

// EVENTS
Battle_Animation :: struct {
	draw:   proc(dt: f32, offset: Pixel_Coord),
	// animation: Animation,
	offset: Pixel_Coord,
}

Battle_Message :: struct {
	text: cstring,
}

Battle_Event :: union {
	Battle_Animation,
	Battle_Message,
	Character_Effect,
}

// STATE
Next_Event :: struct {}
Next_Turn :: struct {}
Take_Turn :: struct {
	actor_idx: int,
}
Process_Battle_Animation :: struct {
	draw:   proc(dt: f32, offset: Pixel_Coord),
	// animation: Animation,
	offset: Pixel_Coord,
	t:      f32,
}
// Process_Battle_Message :: struct {
// 	text: cstring,
// }
Battle_State :: union {
	Next_Event,
	Next_Turn,
	Take_Turn,
	Process_Battle_Animation,
}

Turn_Proc :: proc(actor_idx: int)
