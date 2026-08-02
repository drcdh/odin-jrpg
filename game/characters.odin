package game

import "core:fmt"
import "core:math"
import "core:strings"

Character :: struct {
	base_stats:    Stats,
	exp_to_next:   Maybe(int),
	hitpoints:     int,
	level:         int,
	leveled_stats: Stats,
	name:          cstring,
	equipment:     Equipment,
	using stats:   Stats,
	using status:  Status,
	skills:        Skill_Set_C,
}

exp_to_next :: proc(level: int) -> Maybe(int) {
	if level >= MAX_LEVEL {
		return nil
	}
	return 1 * int(math.pow(f32(level), 2.5))
}

set_level :: proc(c: ^Character, level: int) {
	c.exp_to_next = exp_to_next(level)
	c.level = level
	c.leveled_stats = leveled_stats(c.level, c.base_stats, {})
	c.stats = equipped_stats(c.leveled_stats, c.equipment)
}

gain_level :: proc(c: ^Character, runner_idx: Maybe(int)) -> Maybe(int) {
	set_level(c, c.level + 1)
	return queue_events(
		[]Event {
			Append_Text_Ex{text = fmt.aprintf("%s got to level %d!", c.name, c.level), hurry = true, pause = 1, lines = 2}, // FIXME: leak?
			Clear_Text{},
		},
		i = runner_idx,
		battle = true,
	)
}

get_experience :: proc(c: ^Character, exp: int, runner_idx: Maybe(int)) -> Maybe(int) {
	runner_idx := runner_idx
	for exp := exp; exp > 0; {
		fmt.printfln("~ get %d exp", exp)
		if exp_needed, ok := c.exp_to_next.(int); ok {
			if exp >= exp_needed {
				runner_idx = gain_level(c, runner_idx)
				exp -= exp_needed
			} else {
				c.exp_to_next = exp_needed - exp
				exp = 0
			}
		}
	}
	return runner_idx
}

party_get_experience :: proc(exp: int) -> Maybe(int) {
	runner_idx: Maybe(int)
	if exp <= 0 {return runner_idx}
	for party_idx in 0 ..< party_size() {
		pc_idx := get_party_member(party_idx).? or_break
		pc := get_pc(pc_idx)
		runner_idx = get_experience(pc, exp, runner_idx)
	}
	return runner_idx
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
