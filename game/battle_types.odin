package game

Combatant :: struct {
	character: Character,
	enabled:   bool,
	t:         int,
	team:      int,
	turn:      Turn_Proc,
}

Battle_Animation :: struct {
	draw:   proc(dt: f32, offset: Pixel_Coord),
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

// Battle_Action_Type :: struct {
// 	name:   cstring,
// 	effect: Character_Effect,
// }

Next :: struct {}
Process :: struct {}
Turn :: struct {
	actor_idx: int,
}
// Battle_Action :: struct {
// 	actor:  int,
// 	target: int,
// 	type:   Battle_Action_Type,
// 	idx:    int,
// }

Battle_State :: union {
	Next,
	Process,
	Turn,
}

Turn_Proc :: proc(actor_idx: int)
