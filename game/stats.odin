package game

import "core:fmt"

NUM_STATS :: 6

Stat :: enum {
	Hitpoints,
	Offense,
	Defense,
	PsyOffense,
	PsyDefense,
	Speed,
}

Stats :: struct {
	hitpoints, offense, defense, pOffense, pDefense, speed: int,
}

stat_string :: proc(s: Stats, i: Stat) -> string {
	switch i {
	case .Hitpoints:
		return fmt.aprintf("HP:         % 4d", s.hitpoints)
	case .Offense:
		return fmt.aprintf("Offense:    % 4d", s.offense)
	case .Defense:
		return fmt.aprintf("Defense:    % 4d", s.defense)
	case .PsyOffense:
		return fmt.aprintf("P. Offense: % 4d", s.pOffense)
	case .PsyDefense:
		return fmt.aprintf("P. Defense: % 4d", s.pDefense)
	case .Speed:
		return fmt.aprintf("Speed:      % 4d", s.speed)
	}
	return "bad_stat_index"
}
