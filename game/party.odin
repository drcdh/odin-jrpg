package game

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
	base_stats = {max_hitpoints = 10, offense = 5, defense = 5, psy_offense = 5, psy_defense = 5, speed = 5},
}

ASSASSIN := Character {
	name = "Paula",
	// name      = "Assassin",
	base_stats = {max_hitpoints = 8, offense = 9, defense = 4, psy_offense = 7, psy_defense = 7, speed = 10},
}

MUSICIAN := Character {
	name = "Pete",
	base_stats = {max_hitpoints = 9, offense = 4, defense = 4, psy_offense = 6, psy_defense = 8, speed = 9},
}

KILLER := Character {
	name = "Killer",
	base_stats = {max_hitpoints = 5, offense = 1, defense = 2, psy_offense = 10, psy_defense = 10, speed = 5},
}

MOURNER := Character {
	name = "Mourner",
	base_stats = {max_hitpoints = 5, offense = 3, defense = 3, psy_offense = 10, psy_defense = 10, speed = 5},
}

ZEALOT := Character {
	name = "Zealot",
	base_stats = {max_hitpoints = 11, offense = 8, defense = 8, psy_offense = 4, psy_defense = 5, speed = 7},
}

get_pc_PC :: proc(pc: PC) -> ^Character {
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

get_pc_int :: proc(pc: int) -> ^Character {
	return get_pc_PC(PC(pc))
}

get_pc :: proc {
	get_pc_PC,
	get_pc_int,
}

pc_idle_anim := [NUM_PC]Animation_Name {
	.Protagonist_Battle,
	.Woman_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
	.Protagonist_Battle,
}

pc_idle_texture := [NUM_PC]Texture_Name {
	.Protagonist_Battle0,
	.Woman_Battle0,
	.Protagonist_Battle0,
	.Protagonist_Battle0,
	.Protagonist_Battle0,
	.Protagonist_Battle0,
}

get_party_member :: proc(i: int) -> Maybe(PC) {
	ii := -1
	for pc_idx in 0 ..< NUM_PC {
		if game_data.party_membership[pc_idx] {ii += 1}
		if ii == i {return PC(pc_idx)}
	}
	return nil
}

party_size :: proc() -> int {
	size := 0
	for party_idx in 0 ..< NUM_PC {
		if game_data.party_membership[party_idx] {
			size += 1
		}
	}
	return size
}

get_skill_set :: proc(pc: PC, equipment: Equipment, level: int, stats: Stats) -> Skill_Set {
	f: proc(_: Equipment, _: int, _: Stats) -> Skill_Set
	switch pc {
	case .Protagonist:
		f = get_protagonist_skill_set
	case .Assassin:
		f = get_assassin_skill_set
	case .Musician:
		f = get_musician_skill_set
	case .Killer:
		f = get_killer_skill_set
	case .Mourner:
		f = get_mourner_skill_set
	case .Zealot:
		f = get_zealot_skill_set
	}
	return f(equipment, level, stats) | get_generic_skill_set(equipment, level, stats)
}

get_generic_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	mh := equipped_item(equipment, Equipment_Slot.Mainhand)
	if mh == .Sword || mh == .Knife {
		skill_set += {.Slash}
		if level >= 10 {
			skill_set += {.Slash_All}
		}
	} else if mh == .Rat_Smashing_Bat {
		skill_set += {.Smash}
	} else if mh == .None {
		skill_set += {.Punch}
	}
	return
}

get_protagonist_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	mh := equipped_item(equipment, Equipment_Slot.Mainhand)
	if mh == .Sword || mh == .Knife {
		if level >= 2 {
			skill_set += {.Pommel_Strike}
		}
	}
	return
}

get_assassin_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	skill_set += {.Mind_Control}
	return
}

get_musician_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	return
}

get_killer_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	return
}

get_mourner_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	return
}

get_zealot_skill_set :: proc(equipment: Equipment, level: int, stats: Stats) -> (skill_set: Skill_Set) {
	return
}

set_skills_int :: proc(i: int) {
	pc := get_pc(i)
	pc.skills = get_skill_set(PC(i), pc.equipment, pc.level, pc.stats)
}

set_skills_enum :: proc(i: PC) {
	set_skills_int(int(i))
}

set_skills :: proc {
	set_skills_int,
	set_skills_enum,
}

set_all_skills :: proc() {
	for i in 0 ..< len(PC) {
		set_skills(i)
	}
}

heal_party :: proc(f := 1) {
	for i in 0 ..< len(PC) {
		pc := get_pc(i)
		pc.hitpoints = pc.max_hitpoints / f
	}
}
