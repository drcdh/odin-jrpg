package game

MAX_ENCOUNTER_SIZE :: 6

start_encounter_0 :: proc() {
	battle_combatants[0] = new_mouse_sized_rat()
	battle_combatants[1] = new_mouse_sized_rat()
	battle_combatants[2] = new_rat_sized_mouse()
	battle_num_combatants = 3
	for slot, i in PARTY_ROSTER {
		switch slot {
		case .Empty:
		case .Protagonist:
			battle_combatants[3+i] = Combatant {
				character = PROTAGONIST,
				enabled = true,
				t = 18,
				team = 1,
				turn = PC_COMBATANT_TURN,
			}
			battle_num_combatants += 1
		}
	}
	battle_active = true
}
