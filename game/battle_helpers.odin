package game

import "core:fmt"

get_combatant_not_on_team :: proc(actor_team: int) -> int {
	// todo: just take first for now
	for bc, i in battle_combatants {
		if bc.enabled && bc.character.stats.hitpoints > 0 && bc.team != actor_team {
			return i
		}
	}
	return MAX_COMBATANTS // fixme
}

get_combatant_ref :: proc(idx: int) -> ^Character {
	if battle_combatants[idx].enabled {
		fmt.println("returning reference to", battle_combatants[idx])
		return &battle_combatants[idx].character
	}
	return nil
}
