package game

PARTY_SIZE :: 6

Party_Slot :: enum {
	Empty,
	Protagonist,
}

PARTY_ROSTER :: [PARTY_SIZE]Party_Slot {
	Party_Slot.Protagonist,
	Party_Slot.Empty,
	Party_Slot.Empty,
	Party_Slot.Empty,
	Party_Slot.Empty,
	Party_Slot.Empty,
}

PROTAGONIST := Character {
	name = "Player",
	stats = Stats{hitpoints = 10, offense = 5, defense = 5},
}
