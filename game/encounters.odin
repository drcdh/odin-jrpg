package game

import hm "core:container/handle_map"

MAX_ENCOUNTER_SIZE :: 6

Encounter :: struct {
	baddies: [MAX_ENCOUNTER_SIZE]Baddy_Id,
}

encounters := [?]Encounter{
	{baddies={.Mouse_Sized_Rat, .Mouse_Sized_Rat, .Rat_Sized_Mouse, .None, .None, .None}},
}

add_baddy_combatant :: proc(baddy_id: Baddy_Id) {
	if template := get_baddy_template(baddy_id); template != nil {
		battle_baddies[battle_num_baddies] = Character{
			name = template.name,
			stats = template.stats,
		}
		battle_baddy_handles[battle_num_baddies] = hm.add(&battle_combatants, Combatant{
			character = &battle_baddies[battle_num_baddies],
			coord = Pixel_Coord{64, f32(64+64*battle_num_baddies)},
			enabled = true,
			turn = template.turn,
		})
		battle_num_baddies += 1
	}
}

start_encounter :: proc(i: int) {
	battle_num_baddies = 0

	for baddy_id in encounters[i].baddies {
		add_baddy_combatant(baddy_id)
	}
	for pc_idx in 0..<NUM_PC {
		_ = hm.add(&battle_combatants, Combatant{
			character = get_pc(PC(pc_idx)),
			coord = Pixel_Coord{480, f32(96+64*pc_idx)},
			enabled = true,
			team = 1,
			turn = PC_COMBATANT_TURN,
		})
	}
	battle_active = true
	battle_ending = false
	battle_state = Next_Turn{}
}
