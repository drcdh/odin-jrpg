package game

import rl "vendor:raylib"

Combatant :: struct {
	using character: ^Character,
	coord:           Pixel_Coord,
	enabled:         bool,
	id:              int,
	t:               int,
	team:            int,
	turn:            Turn_Proc,
	visual:          Combatant_Visual,
	windup:          bool,
}

Combatant_Visual_Variant :: union {
	Animation,
	Texture_Name,
}

Combatant_Visual :: struct {
	tint:    rl.Color,
	variant: Combatant_Visual_Variant,
}

// TURN
Battle_Skill_Play :: struct {
	actor:   int,
	targets: Target_Selection,
	skill:   Skill,
	windup:  int,
}

Battle_Turn_Order :: struct {
	c_idx:  int,
	staged: bool,
}

// EVENTS
Battle_Event :: union {
	Battle_Effect_Event,
	Play_Animation,
	Play_Sound,
	Text_Effect,
}

// STATE
Next_Event :: struct {}
Next_Turn :: struct {}
Take_Turn :: struct {
	c_idx: int,
	t:     f32,
}
Process_Battle_Animation :: struct {
	animation: Animation,
	offset:    Pixel_Coord,
	t:         f32,
}
Process_Text_Effect :: struct {
	color: rl.Color,
	coord: Pixel_Coord,
	t:     f32,
	text:  cstring,
}
Process_Skill :: struct {
	skill_idx: int,
	step:      int,
	t:         f32,
}
Battle_State :: union {
	Next_Turn,
	Take_Turn,
	Process_Skill,
}

Turn_Proc :: proc(actor_idx: int)
