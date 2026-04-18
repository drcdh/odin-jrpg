package game

import "core:fmt"

Battle_State :: struct {}

Stat :: int

Character_State :: struct {
	stats: Stats
}

CHARACTER_EFFECT :: proc(actor_state, character_state: ^Character_State)

Character_Effect :: struct {
	f: CHARACTER_EFFECT,
}

Battle_Effect :: union {
	Character_Effect,
}

CE_ATTACK :: Character_Effect {
	f = proc(actor_state, target_state: ^Character_State) {
		target_state.stats.hitpoints -= actor_state.stats.offense
	}
}

Battle_Action :: struct {
	name: cstring,
	// effect: Battle_Effect,
	effect: Character_Effect,
	// message: cstring,
}

BA_ATTACK :: Battle_Action {
	name = "Attack",
	effect = CE_ATTACK,
	// message = "{:actor} attacks {:target}!",
}

Stats :: struct {
	hitpoints : Stat,
	offense : Stat,
	defense : Stat,
}

Turn :: proc(Battle_State) -> Battle_Action

Baddy :: struct {
	stats: Stats,
	name: string,
	turn: Turn,
}

NULL_BADDY :: Baddy{}

MOUSE_SIZED_RAT :: Baddy{
	stats = Stats{hitpoints=1, offense=1, defense=1},
	name = "Mouse-Sized Rat",
	turn = proc(bs: Battle_State) -> Battle_Action {
		return BA_ATTACK
	},
}

RAT_SIZED_MOUSE :: Baddy{
	stats = Stats{hitpoints=3, offense=3, defense=2},
	name = "Rat-Sized Mouse",
	turn = proc(bs: Battle_State) -> Battle_Action {
		return BA_ATTACK
	},
}

MAX_ENCOUNTER_SIZE :: 6

Encounter :: struct {
	baddies: [MAX_ENCOUNTER_SIZE]Baddy,
	size: int,
}

ENC_0 :: Encounter {
	baddies = {
		MOUSE_SIZED_RAT,
		MOUSE_SIZED_RAT,
		RAT_SIZED_MOUSE,
		NULL_BADDY,
		NULL_BADDY,
		NULL_BADDY,
	},
	size=3,
}
