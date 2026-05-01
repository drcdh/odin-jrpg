package game

import "core:fmt"
import hm "core:container/handle_map"
import rl "vendor:raylib"

MAX_ENCOUNTER_SIZE :: 6

Encounter :: struct {
	baddies: [MAX_ENCOUNTER_SIZE]Baddy_Id,
}

encounters := [?]Encounter{
	{baddies = {.Mouse_Sized_Rat, .None, .None, .None, .None, .None}},
	{baddies = {.Mouse_Sized_Rat, .Mouse_Sized_Rat, .Rat_Sized_Mouse, .None, .None, .None}},
	{baddies = {.Mouse_Sized_Rat, .Mouse_Sized_Rat, .Rat_Sized_Mouse, .Mouse_Sized_Rat, .Mouse_Sized_Rat, .Mouse_Sized_Rat}},
}

add_baddy_combatant :: proc(baddy_id: Baddy_Id) {
	if template := get_baddy_template(baddy_id); template != nil {
		fmt.printfln("adding %s (baddy_id=%d) at index %d", template.name, baddy_id, battle_num_baddies)
		battle_baddies[battle_num_baddies] = Character {
			name  = template.name,
			stats = template.stats,
		}
		battle_baddy_handles[battle_num_baddies] = hm.add(
			&battle_combatants,
			Combatant {
				character = &battle_baddies[battle_num_baddies],
				coord = Pixel_Coord{64, f32(64 + 128 * battle_num_baddies)},
				enabled = true,
				turn = template.turn,
				visual = {variant = template.texture, tint = rl.WHITE},
			},
		)
		battle_num_baddies += 1
	}
}

start_encounter :: proc(i: int) {
	battle_num_baddies = 0
	battle_num_pc = 0

	for baddy_id in encounters[i].baddies {
		add_baddy_combatant(baddy_id)
	}

	dy : f32 = 128
	y0 : f32 = 192
	x : f32 = 480
	y : f32 = y0
	for pc_idx in 0 ..< NUM_PC {
		battle_pc_handles[battle_num_pc] = hm.add(
			&battle_combatants,
			Combatant {
				character = get_pc(PC(pc_idx)),
				coord = {x, y},
				enabled = true,
				team = 1,
				turn = PC_COMBATANT_TURN,
				visual = {variant=animation_create(pc_idle_anim[pc_idx]), tint=pc_idle_anim_tint[pc_idx]},
			},
		)
		battle_num_pc += 1
		x += 32
		if battle_num_pc != 3 {
			y += dy
		} else {
			x += 128
			y = y0 + dy/2
		}
	}
	battle_active = true
	battle_ending = false
	battle_state = Next_Turn{}
}
