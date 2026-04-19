package game

MAX_ENCOUNTER_SIZE :: 6

start_encounter_0 :: proc() {
	battle_combatants[0] = Combatant{variant=new_mouse_sized_rat()}
	battle_combatants[1] = Combatant{variant=new_mouse_sized_rat()}
	battle_combatants[2] = Combatant{variant=new_rat_sized_mouse()}

	battle_combatants[3] = Combatant {
		variant = PC_Combatant{
			pc = &STAND_IN,
		}
	}
	battle_num_combatants = 4
	battle_active = true
}

