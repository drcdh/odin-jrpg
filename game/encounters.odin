package game

import "core:fmt"
import rl "vendor:raylib"

MAX_ENCOUNTER_SIZE :: 6

BADDY_TEAM :: 0
PLAYER_TEAM :: 1

BATTLE_ORIGIN_TILE :: Tile_Coord{3, 3}

Encounter_Spot :: struct {
	tile:     Tile_Coord,
	baddy_id: Baddy_Id,
}

Encounter :: struct {
	baddies: [MAX_ENCOUNTER_SIZE]Encounter_Spot,
}

encounters := [?]Encounter {
	{baddies = {{{0, 0}, .Mouse_Sized_Rat}, {{0, 2}, .Mouse_Sized_Rat}, {}, {}, {}, {}}},
	{
		baddies = {
			{{0, 0}, .Mouse_Sized_Rat},
			{{0, 1}, .Mouse_Sized_Rat},
			{{0, 3}, .Malicious_Mushroom},
			{{1, 1}, .Generic_Goblin_1},
			{{-2, 1}, .Magic_Serpent},
			{},
		},
	},
	{
		baddies = {
			{{0, 0}, .Mouse_Sized_Rat},
			{{1, 0}, .Mouse_Sized_Rat},
			{{2, 0}, .Mouse_Sized_Rat},
			{{0, 1}, .Mouse_Sized_Rat},
			{{1, 1}, .Mouse_Sized_Rat},
			{{2, 1}, .Mouse_Sized_Rat},
		},
	},
	{
		baddies = {
			{{0, 0}, .Mouse_Sized_Rat},
			{{1, 0}, .Mouse_Sized_Rat},
			{{1, 1}, .Rat_Sized_Mouse},
			{{0, 2}, .Mouse_Sized_Rat},
			{{1, 2}, .Mouse_Sized_Rat},
			{{2, 2}, .Mouse_Sized_Rat},
		},
	},
	{baddies = {{{0, 0}, .Bad_Box}, {{0, 3}, .Bad_Box}, {{0, 5}, .Bad_Box}, {}, {}, {}}},
}

start_encounter :: proc(i: int, paused: bool) {
	for spot in encounters[i].baddies {
		baddy_id := spot.baddy_id
		if baddy_id == .None {continue}
		template := baddy_templates[baddy_id]
		fmt.printfln("adding %s (baddy_id=%d)", template.name, baddy_id)
		baddy := new(Character)
		baddy.name = template.name
		baddy.hitpoints = template.stats.max_hitpoints
		baddy.stats = template.stats
		visual_variant: Combatant_Visual_Variant
		switch t in template.texture {
		case Texture_Name:
			visual_variant = t
		case Animation_Name:
			visual_variant = animation_create(t)
		}
		append(&battle.baddies, len(battle.combatants))
		append(
			&battle.combatants,
			Combatant {
				character = baddy,
				coord = tile_to_pixel(BATTLE_ORIGIN_TILE + spot.tile),
				enabled = true,
				team = BADDY_TEAM,
				turn = template.turn,
				visual = {variant = visual_variant, tint = rl.WHITE},
			},
		)
	}

	dy: f32 = 2 * tile_size
	y0: f32 = 2 * tile_size
	x: f32 = 9.5 * tile_size
	y: f32 = y0
	party_idx := 0
	for pc_idx in 0 ..< NUM_PC {
		if game_data.party_membership[pc_idx] {
			append(&battle.allies, len(battle.combatants))
			append(
				&battle.combatants,
				Combatant {
					character = get_pc(PC(pc_idx)),
					coord = {x, y},
					enabled = true,
					t = READY_T,
					team = PLAYER_TEAM,
					visual = {variant = animation_create(pc_idle_anim[pc_idx]), tint = rl.WHITE},
				},
			)
			party_idx += 1
			x += tile_size
			if party_idx != 3 {
				y += dy
			} else {
				// x += 4 * tile_size
				y = y0 + dy / 2
			}
		}
	}
	battle.active = true
	battle.ending = false
	battle.paused = paused
	battle_init()

	play_music(&music_state, .Battle)
}
