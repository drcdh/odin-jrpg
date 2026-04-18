package game

import "core:fmt"

import rl "vendor:raylib"

MAX_PARTY_SIZE :: 6

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + MAX_PARTY_SIZE

battle_combatants:= [MAX_COMBATANTS]Combatant{}
battle_active := false
battle_num_combatants := 0

PC :: struct {}

Combatant_Variant :: union {
	Baddy,
	PC,
}

Combatant :: struct {
	state: Character_State,
	variant: Combatant_Variant,
}

new_state :: proc(stats: Stats) -> Character_State {
	return Character_State {
		stats = Stats {
		hitpoints = stats.hitpoints,
		offense = stats.offense,
		defense = stats.defense,
	}}
}

new_baddy :: proc(b: Baddy) -> Combatant {
	return Combatant{
		state = new_state(b.stats),
		variant = b,
	}
}

Party :: struct {
	members : [MAX_PARTY_SIZE]PC,
	size: int,
}

start_encounter :: proc(encounter: Encounter) {
	battle_num_combatants = 0
	for i in 0..<encounter.size {
		battle_combatants[i] = new_baddy(encounter.baddies[i])
		battle_num_combatants += 1
	}
	for i in 0..<party.size { battle_combatants[encounter.size + i] = Combatant {
		state = new_state(Stats{
			hitpoints = 10,
			offense = 5,
			defense = 5,
		}),
		variant = PC{},
	}
		battle_num_combatants += 1
}
	battle_active = true
}

draw_battle :: proc() {
		rl.DrawRectangleV(Pixel_Coord{50, 50}, Pixel_Dim{800, 800}, TEXT_DISPLAY_BACKGROUND)
		y := i32(0)
		for i in 0..<battle_num_combatants {
			y += 60
			c := battle_combatants[i]
			rl.DrawText(fmt.caprintf("%d/%d: %w", i+1, battle_num_combatants, c.state), 60, y, 18, TEXT_COLOR)
		}
}
