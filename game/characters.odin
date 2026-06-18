package game

import "core:strings"

Character :: struct {
	base_stats:      Stats,
	hitpoints:       int,
	level:           int,
	leveled_stats:   Stats,
	name:            cstring,
	using equipment: Equipment,
	using stats:     Stats,
	using status:    Status,
	skills:          Skill_Set,
}

set_level :: proc(c: ^Character, level: int) {
	c.level = level
	c.leveled_stats = leveled_stats(c.level, c.base_stats, {})
	c.stats = equipped_stats(c.leveled_stats, c.equipment)
}

Status :: struct {
	confuse: bool,
	control: bool,
	poison:  bool,
	zombie:  bool,
}

get_status_cstring :: proc(status: Status) -> cstring {
	s := ""
	if status.poison {
		s = strings.concatenate({s, "P"}, context.temp_allocator)
	}
	if status.zombie {
		s = strings.concatenate({s, "Z"}, context.temp_allocator)
	}
	return strings.clone_to_cstring(s)
}
