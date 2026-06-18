package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

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
	max_hitpoints, offense, defense, psy_offense, psy_defense, speed: int,
}

get_stat :: proc(stats: Stats, i: Stat) -> int {
	switch i {
	case .Hitpoints:
		return stats.max_hitpoints
	case .Offense:
		return stats.offense
	case .Defense:
		return stats.defense
	case .PsyOffense:
		return stats.psy_offense
	case .PsyDefense:
		return stats.psy_defense
	case .Speed:
		return stats.speed
	}
	return -1
}

get_stat_f :: proc(stats: Stats, i: Stat) -> f32 {
	return f32(get_stat(stats, i))
}

set_stat :: proc(stats: ^Stats, i: Stat, v: int) {
	switch i {
	case .Hitpoints:
		stats.max_hitpoints = v
	case .Offense:
		stats.offense = v
	case .Defense:
		stats.defense = v
	case .PsyOffense:
		stats.psy_offense = v
	case .PsyDefense:
		stats.psy_defense = v
	case .Speed:
		stats.speed = v
	}
}

lfunc :: proc(level, base, points: int) -> int {
	return base * level + points * int(math.sqrt(f32(level))) / 4
}

leveled_stats :: proc(level: int, base, points: Stats) -> (leveled: Stats) {
	leveled.max_hitpoints = lfunc(level, base.max_hitpoints, points.max_hitpoints)
	leveled.offense = lfunc(level, base.offense, points.offense)
	leveled.defense = lfunc(level, base.defense, points.defense)
	leveled.psy_offense = lfunc(level, base.psy_offense, points.psy_offense)
	leveled.psy_defense = lfunc(level, base.psy_defense, points.psy_defense)
	leveled.speed = lfunc(level, base.speed, points.speed)
	return
}

equipped_stat :: proc(lstats: Stats, i: Stat, equipment: Equipment) -> int {
	add := 0
	mul: f32 = 100.0
	lstat := get_stat_f(lstats, i)
	for slot in 0 ..< NUM_EQUIPMENT_SLOTS {
		item_name := equipped_item(equipment, slot)
		if item_name == .None {continue}
		item := items[item_name]
		eq := item.data.(Equippable) or_continue
		add += get_stat(eq.stats_add, i)
		mul += get_stat_f(eq.stats_mul, i)
	}
	return int(lstat * mul / 100) + add
}

equipped_stats :: proc(lstats: Stats, equipment: Equipment) -> (final: Stats) {
	for i in 0 ..< NUM_STATS {
		i := Stat(i)
		set_stat(&final, i, equipped_stat(lstats, i, equipment))
	}
	return
}

stat_string :: proc(s: Stats, i: Stat) -> string {
	switch i {
	case .Hitpoints:
		return fmt.aprintf("Max HP:     % 4d", s.max_hitpoints)
	case .Offense:
		return fmt.aprintf("Offense:    % 4d", s.offense)
	case .Defense:
		return fmt.aprintf("Defense:    % 4d", s.defense)
	case .PsyOffense:
		return fmt.aprintf("P. Offense: % 4d", s.psy_offense)
	case .PsyDefense:
		return fmt.aprintf("P. Defense: % 4d", s.psy_defense)
	case .Speed:
		return fmt.aprintf("Speed:      % 4d", s.speed)
	}
	return "bad_stat_index"
}

change_tint :: proc(prev, next: int) -> (tint := rl.WHITE) {
	if next > prev {tint = rl.GREEN}
	if next < prev {tint = rl.RED}
	return
}
