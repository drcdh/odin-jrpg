package game

MAX_PARTY_SIZE :: 6

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + MAX_PARTY_SIZE

	battle_combatants:= [MAX_COMBATANTS]Combatant{}
	battle_active := false

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
	for i in 0..<encounter.size { battle_combatants[i] = new_baddy(encounter.baddies[i])}
	for i in 0..<party.size { battle_combatants[encounter.size + i] = Combatant {
		state = new_state(Stats{
			hitpoints = 10,
			offense = 5,
			defense = 5,
		}),
		variant = PC{},
	}
}
	battle_active = true
}

