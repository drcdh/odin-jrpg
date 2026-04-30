package game

import hm "core:container/handle_map"

target := -1

change_target :: proc(d: int) {
	initial_target := target
	for {
		target += d
		if target < 0 {target = MAX_ENCOUNTER_SIZE - 1}
		if target >= MAX_ENCOUNTER_SIZE {target = 0}
		if target == initial_target {return}
		if c, ok := hm.get(&battle_combatants, battle_baddy_handles[target]); ok {
			if c.enabled {return}
		}
	}
}
