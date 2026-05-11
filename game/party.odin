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
	name      = "Player",
	hitpoints = 10,
	offense   = 5,
	defense   = 5,
	pOffense  = 5,
	pDefense  = 5,
	speed     = 5,
}

ASSASSIN := Character {
	name      = "Assassin",
	hitpoints = 8,
	offense   = 9,
	defense   = 4,
	pOffense  = 7,
	pDefense  = 7,
	speed     = 10,
}

MUSICIAN := Character {
	name      = "Pete",
	hitpoints = 9,
	offense   = 4,
	defense   = 4,
	pOffense  = 6,
	pDefense  = 8,
	speed     = 9,
}

KILLER := Character {
	name      = "Killer",
	hitpoints = 5,
	offense   = 1,
	defense   = 2,
	pOffense  = 10,
	pDefense  = 10,
	speed     = 5,
}

MOURNER := Character {
	name      = "Mourner",
	hitpoints = 5,
	offense   = 3,
	defense   = 3,
	pOffense  = 10,
	pDefense  = 10,
	speed     = 5,
}

ZEALOT := Character {
	name      = "Zealot",
	hitpoints = 11,
	offense   = 8,
	defense   = 8,
	pOffense  = 4,
	pDefense  = 5,
	speed     = 7,
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
