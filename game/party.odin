package game

MAX_PARTY_SIZE :: 6

PC :: Character

Party :: struct {
	members: [MAX_PARTY_SIZE]PC,
	size:    int,
}

STAND_IN := PC {
	name = "Player",
	stats = Stats{hitpoints = 10, offense = 5, defense = 5},
}
