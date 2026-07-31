package game

import rl "vendor:raylib"

Ticks :: f32

Combatant :: struct {
	using character: ^Character,
	coord:           Pixel_Coord,
	enabled:         bool,
	id:              int,
	t:               Ticks,
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

Battle_Skill_Play :: struct {
	actor:   int,
	targets: Target_Selection,
	skill:   Skill,
	windup:  Ticks,
}

Process_Battle_Animation :: struct {
	animation: Animation,
	delay:     f32,
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
	active:          bool,
	skill_plays_idx: int,
	step:            int,
	t:               f32,
}

Turn_Proc :: proc(actor_idx: int)

Battle_Result :: enum {
	Lose,
	Win,
}
