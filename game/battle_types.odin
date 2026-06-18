package game

import hm "core:container/handle_map"
import rl "vendor:raylib"

Combatant_Handle :: distinct hm.Handle16

Combatant :: struct {
	using character: ^Character,
	coord:           Pixel_Coord,
	enabled:         bool,
	handle:          Combatant_Handle,
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
	actor:  ^Combatant,
	target: ^Combatant, // TODO multiple targets
	skill:  Skill,
	windup: int,
}

Battle_Turn_Order :: struct {
	h:      Combatant_Handle,
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
	actor_h: Combatant_Handle,
	t:       f32,
}
Process_Battle_Animation :: struct {
	animation: Animation,
	offset:    Pixel_Coord,
	t:         f32,
}
Process_Text_Effect :: struct {
	coord: Pixel_Coord,
	t:     f32,
	text:  cstring,
}
Battle_State :: union {
	Next_Event,
	Next_Turn,
	Take_Turn,
	Process_Battle_Animation,
	Process_Text_Effect,
}

Turn_Proc :: proc(actor: ^Combatant)
