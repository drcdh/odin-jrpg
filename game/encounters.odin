package game

import hm "core:container/handle_map"
import "core:fmt"
import rl "vendor:raylib"

MAX_ENCOUNTER_SIZE :: 6

BATTLE_ORIGIN_TILE :: Tile_Coord{3, 3}

Encounter_Spot :: struct {
	tile: Tile_Coord,
	baddy_id: Baddy_Id,
}

Encounter :: struct {
	baddies: [MAX_ENCOUNTER_SIZE]Encounter_Spot,
}

encounters := [?]Encounter {
	{baddies = {
							 {{0, 0}, .Mouse_Sized_Rat},
							 // {{0, 3}, .Malicious_Mushroom},
							 // {{1, 1}, .Generic_Goblin_1},
							 {},{},
							 {},{},{}}},
	{baddies = {
							 {{0, 0}, .Mouse_Sized_Rat},
							 {{1, 0}, .Mouse_Sized_Rat},
							 {{2, 0}, .Mouse_Sized_Rat},
							 {{0, 1}, .Mouse_Sized_Rat},
							 {{1, 1}, .Mouse_Sized_Rat},
							 {{2, 1}, .Mouse_Sized_Rat},
						 }},
	{baddies = {
							 {{0, 0}, .Mouse_Sized_Rat},
							 {{1, 0}, .Mouse_Sized_Rat},
							 {{1, 1}, .Rat_Sized_Mouse},
							 {{0, 2}, .Mouse_Sized_Rat},
							 {{1, 2}, .Mouse_Sized_Rat},
							 {{2, 2}, .Mouse_Sized_Rat},
	}},
}

add_baddy_combatant :: proc(baddy_id: Baddy_Id, tile: Tile_Coord) {
	if baddy_id == .None { return }
	template := baddy_templates[baddy_id]
	fmt.printfln("adding %s (baddy_id=%d) at index %d", template.name, baddy_id, battle_num_baddies)
	battle_baddies[battle_num_baddies] = Character {
		name  = template.name,
		stats = template.stats,
	}
	visual_variant: Combatant_Visual_Variant
	switch t in template.texture {
	case Texture_Name:
		visual_variant = t
	case Animation_Name:
		visual_variant = animation_create(t)
	}
	battle_baddy_handles[battle_num_baddies] = hm.add(
		&battle_combatants,
		Combatant {
			character = &battle_baddies[battle_num_baddies],
			coord = tile_to_pixel(BATTLE_ORIGIN_TILE + tile),
			enabled = true,
			turn = template.turn,
			visual = {variant = visual_variant, tint = rl.WHITE},
		},
	)
	battle_num_baddies += 1
}

start_encounter :: proc(i: int) {
	battle_num_baddies = 0
	battle_num_pc = 0

	for spot in encounters[i].baddies {
		add_baddy_combatant(spot.baddy_id, spot.tile)
	}

	dy: f32 = 2 * tile_size
	y0: f32 = 2 * tile_size
	x: f32 = 9.5 * tile_size
	y: f32 = y0
	for pc_idx in 0 ..< NUM_PC {
		battle_pc_handles[battle_num_pc] = hm.add(
			&battle_combatants,
			Combatant {
				character = get_pc(PC(pc_idx)),
				coord = {x, y},
				enabled = true,
				team = 1,
				turn = pc_turn,
				visual = {variant = animation_create(pc_idle_anim[pc_idx]), tint = pc_idle_anim_tint[pc_idx]},
			},
		)
		battle_num_pc += 1
		x += tile_size
		if battle_num_pc != 3 {
			y += dy
		} else {
			// x += 4 * tile_size
			y = y0 + dy / 2
		}
	}
	battle_active = true
	battle_ending = false
	battle_state = Next_Turn{}
}
