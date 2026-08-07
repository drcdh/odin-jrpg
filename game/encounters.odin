package game

import "core:fmt"

MAX_ENCOUNTER_SIZE :: 6

BADDY_TEAM :: 0
PLAYER_TEAM :: 1

BATTLE_ORIGIN_TILE :: Tile_Coord{2, 4}

Encounter_Spot :: struct {
	tile:     Tile_Coord,
	baddy_id: Baddy_Id,
}

Encounter :: struct {
	baddies:     [MAX_ENCOUNTER_SIZE]Encounter_Spot,
	exp:         int,
	init_events: Maybe([]Event),
	lose_events: Maybe([]Event),
	win_events:  Maybe([]Event),
}

encounters := [?]Encounter {
	{baddies = {{{0, 0}, .Mouse_Sized_Rat}, {}, {}, {}, {}, {}}, exp = 1},
	{
		baddies = {
			{{0, 0}, .Mouse_Sized_Rat},
			{{0, 1}, .Mouse_Sized_Rat},
			{{0, 3}, .Malicious_Mushroom},
			{{2, 1}, .Generic_Goblin_1},
			{{-2, 1}, .Magic_Serpent},
			{},
		},
		exp = 1000,
	},
	{
		baddies = {
			{{0, 0}, .Mouse_Sized_Rat},
			{{2, 0}, .Mouse_Sized_Rat},
			{{4, 0}, .Mouse_Sized_Rat},
			{{0, 1}, .Mouse_Sized_Rat},
			{{2, 1}, .Mouse_Sized_Rat},
			{{4, 1}, .Mouse_Sized_Rat},
		},
		exp = 10,
	},
	{
		baddies = {
			{{0, 0}, .Mouse_Sized_Rat},
			{{2, 0}, .Mouse_Sized_Rat},
			{{2, 1}, .Rat_Sized_Mouse},
			{{0, 2}, .Mouse_Sized_Rat},
			{{2, 2}, .Mouse_Sized_Rat},
			{{4, 2}, .Mouse_Sized_Rat},
		},
		exp = 25,
	},
	{baddies = {{{2, 0}, .Bad_Box}, {{2, 2}, .Bad_Box}, {{2, 4}, .Bad_Box}, {{-1, 2}, .Ghost}, {}, {}}, exp = 9999},
	{baddies = {{{2, 0}, .Bad_Box}, {{4, 0}, .Powerful_Pebble}, {}, {}, {}, {}}, exp = 4999},
	{
		baddies = {
			{{2, 0}, .Orthros},
			{{2, 1}, .Tentacle_1},
			{{3, 1}, .Tentacle_2},
			{{4, 1}, .Tentacle_3},
			{{4, 1}, .Tentacle_4},
			{},
		},
		exp = 7654,
	},
}

start_encounter :: proc(i: int, paused: bool) {
	for spot in encounters[i].baddies {
		baddy_id := spot.baddy_id
		if baddy_id == .None {continue}
		template := baddy_templates[baddy_id]
		fmt.printfln("adding %s (baddy_id=%d)", template.name, baddy_id)
		append(&battle.baddies, len(battle.combatants))
		append(
			&battle.combatants,
			Combatant {
				character = new_baddy(template),
				coord = tile_to_pixel(BATTLE_ORIGIN_TILE + spot.tile),
				enabled = true,
				team = BADDY_TEAM,
				turn = template.turn,
				visual = create_sprite_state(template.texture),
			},
		)
	}

	dy: f32 = 2 * tile_size
	y0: f32 = 3 * tile_size
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
					visual = pc_battle_sprites[pc_idx],
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
	battle.encounter = &encounters[i]
	battle.paused = paused
	battle_init()

	play_music(&music_state, .Battle)
}
