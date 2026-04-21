package game

Combatant :: struct {
	character: Character,
	enabled: bool,
	t: int,
	team: int,
	turn: Turn,
}

Battle_Animation :: struct {
	draw: proc(dt: f32, offset: Pixel_Coord),
	offset: Pixel_Coord,
}

Battle_Message :: struct {
  text: cstring,
}

Character_Effect_Proc :: proc(actor, target: ^Stats)

Character_Effect :: struct {
	f: Character_Effect_Proc,
}

Battle_Effect :: union {
	Battle_Animation,
	Battle_Message,
	Character_Effect,
}

Battle_Action_Type :: struct {
	name:   cstring,
	effect: Character_Effect,
}

// Next :: struct {}
// Turn :: struct {actor_idx: int}
Battle_Action :: struct {
	actor: int,
	target: int,
	type: Battle_Action_Type,
	idx: int,
}

// Battle_State :: union {
// 	Next,
// 	Turn,
// 	Battle_Action,
// }

Turn :: proc(actor_idx: int) -> Maybe(Battle_Action)

