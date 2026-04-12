package data

// Battle_State :: struct {}
//
// Stat :: int
//
// Character_State :: Stats
//
// CHARACTER_EFFECT :: proc(actor_state, character_state: ^Character_State)

Character_Effect :: struct {
	// f: CHARACTER_EFFECT,
}

Battle_Effect :: union {
	Character_Effect,
}

CE_ATTACK :: Character_Effect {
	// f = proc(actor_state, target_state: ^Character_State) {
	// 	target_state.hitpoints -= actor_state.offense
	// }
}

Battle_Action :: struct {
	name: cstring,
	effect: Battle_Effect,
	// message: cstring,
}

BA_ATTACK :: Battle_Action {
	name = "Attack",
	// effect = Character_Effect{},
	effect = CE_ATTACK,
	// message = "{:actor} attacks {:target}!",
}

// Stats :: struct {
// 	hitpoints : Stat,
// 	offense : Stat,
// 	defense : Stat,
// }
//
// Turn :: proc(Battle_State) -> Battle_Action
//
// Baddy :: struct {
// 	stats: Stats,
// 	name: string,
// 	turn: Turn,
// }
//
// MOUSE_SIZED_RAT :: Baddy{
// 	stats = Stats{hitpoints=1, offense=1, defense=1},
// 	name = "Mouse-Sized Rat",
// 	turn = proc(bs: Battle_State) -> Battle_Action {
// 		return BA_ATTACK
// 	},
// }
//
// RAT_SIZED_MOUSE :: Baddy{
// 	stats = Stats{hitpoints=3, offense=3, defense=2},
// 	name = "Rat-Sized Mouse",
// 	turn = proc(bs: Battle_State) -> Battle_Action {
// 		return BA_ATTACK
// 	},
// }

main :: proc() {
}
