package game

target := -1

change_target :: proc(d: int) {
	initial_target := target
	for {
		target += d
		if target < 0 {target = MAX_COMBATANTS - 1}
		if target >= MAX_COMBATANTS {target = 0}
		if target == initial_target {return}
		if battle_combatants[target].enabled {return}
	}
}
