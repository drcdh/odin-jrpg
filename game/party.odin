package game

import rl "vendor:raylib"

NUM_PC :: 6

PC :: enum {
	Protagonist = 0,
	Assassin    = 1,
	Musician    = 2,
	Killer      = 3,
	Mourner     = 4,
	Zealot      = 5,
}

PROTAGONIST := Character {
	name = "Player",
	stats = Stats{hitpoints = 10, offense = 5, defense = 5},
}

ASSASSIN := Character {
	name = "Assassin",
	stats = Stats{hitpoints = 8, offense = 9, defense = 4},
}

MUSICIAN := Character {
	name = "Pete",
	stats = Stats{hitpoints = 9, offense = 4, defense = 4},
}

KILLER := Character {
	name = "Killer",
	stats = Stats{hitpoints = 5, offense = 9, defense = 2},
}

MOURNER := Character {
	name = "Mourner",
	stats = Stats{hitpoints = 5, offense = 7, defense = 3},
}

ZEALOT := Character {
	name = "Zealot",
	stats = Stats{hitpoints = 11, offense = 8, defense = 8},
}

get_pc :: proc(pc: PC) -> ^Character {
	switch pc {
	case .Protagonist:
		return &PROTAGONIST
	case .Assassin:
		return &ASSASSIN
	case .Musician:
		return &MUSICIAN
	case .Killer:
		return &KILLER
	case .Mourner:
		return &MOURNER
	case .Zealot:
		return &ZEALOT
	}
	return nil
}

pc_idle_anim := [NUM_PC]Animation_Name {
	.Protagonist_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
}

pc_idle_anim_tint := [NUM_PC]rl.Color{rl.BLACK, rl.RED, rl.BLUE, rl.PURPLE, rl.PINK, rl.ORANGE}
