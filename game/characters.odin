package game

import "core:strings"

Character :: struct {
	base_stats:    Stats,
	hitpoints:     int,
	level:         int,
	leveled_stats: Stats,
	name:          cstring,
	equipment:     Equipment,
	using stats:   Stats,
	using status:  Status,
	skills:        Skill_Set_C,
}

set_level :: proc(c: ^Character, level: int) {
	c.level = level
	c.leveled_stats = leveled_stats(c.level, c.base_stats, {})
	c.stats = equipped_stats(c.leveled_stats, c.equipment)
}

Status_Name :: enum {
	Confuse,
	Control,
	Poison,
	Zombie,
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
	return strings.clone_to_cstring(s, context.temp_allocator)
}

add_status :: proc(c: ^Character, status: Status_Name) {
	switch status {
	case .Confuse:
		c.confuse = true
	case .Control:
		c.control = true
	case .Poison:
		c.poison = true
	case .Zombie:
		c.zombie = true
	}
}

remove_status :: proc(c: ^Character, status: Status_Name) {
	switch status {
	case .Confuse:
		c.confuse = false
	case .Control:
		c.control = false
	case .Poison:
		c.poison = false
	case .Zombie:
		c.zombie = false
	}
}

character_set_equipped_item :: proc(
	character: ^Character,
	slot: Equipment_Slot,
	item: Item_Name,
	from_inventory := true,
	to_inventory := true,
) {
	set_equipped_item(&character.equipment, slot, item, from_inventory, to_inventory)
	character.stats = equipped_stats(character.leveled_stats, character.equipment)
	character.hitpoints = min(character.hitpoints, character.max_hitpoints)
	set_all_skills()
}

character_unequip_all :: proc(character: ^Character, to_inventory := true) {
	unequip_all(&character.equipment, to_inventory)
	character.stats = equipped_stats(character.leveled_stats, character.equipment)
	character.hitpoints = min(character.hitpoints, character.max_hitpoints)
	set_all_skills()
}
