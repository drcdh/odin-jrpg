package game

import "core:fmt"

// Effect_Proc :: proc(actor, target: ^Combatant, effect: Effect)

Effect_Name :: enum {
	Attack,
	Heal_Hp,
	Add_Status,
	Remove_Status,
	Level_Up,
}

Effect_Attack :: struct {
	constant: int,
	power: int,
	psy_power: int,
	pierce: int,
	psy_pierce: int,
	accuracy: int,
	risk: int,
	// traits
	ranged: bool,
}

Effect_Heal_Hp :: struct {
	constant: int,
	power: int,
}

Effect_Add_Status :: struct {
	chance: int,
	status: Status_Name,
}

Effect_Remove_Status :: struct {
	chance: int,
	status: Status_Name,
}

Effect_Level_Up :: struct {
	n: int,
}

Effect :: union {
	Effect_Add_Status,
	Effect_Attack,
	Effect_Heal_Hp,
	Effect_Level_Up,
	Effect_Remove_Status,
}

effect_attack :: proc(actor, target: ^Combatant, effect: Effect_Attack) {
	power := (effect.power / 100)
	pierce := (effect.pierce / 100)
	psy_power := (effect.psy_power / 100)
	psy_pierce := (effect.psy_pierce / 100)
	risk := (effect.risk / 100)
	hp_change := -effect.constant - max(0, power * actor.offense - (1 - pierce)*target.defense) - max(0, psy_power * actor.psy_offense - (1 - psy_pierce)*target.psy_defense)
	target.hitpoints += hp_change
	queue_text_effect(Text_Effect{coord = target.coord, text = fmt.caprintf("%d", hp_change)})
	roll_for_counter(target, actor, risk)
}

effect_heal_hp :: proc(actor, target: ^Character, effect: Effect_Heal_Hp) {
	power := (effect.power / 100)
	amount := effect.constant
	if power > 0 {
		amount += power * actor.psy_offense
	}
	target.hitpoints += amount
	target.hitpoints = min(target.hitpoints, target.max_hitpoints) // TODO: put this everywhere
}

effect_heal_hp_combat :: proc(actor, target: ^Combatant, effect: Effect_Heal_Hp) {
	power := (effect.power / 100)
	amount := effect.constant + power * actor.psy_offense
	target.hitpoints += amount
	target.hitpoints = min(target.hitpoints, target.max_hitpoints) // TODO: put this everywhere
	queue_text_effect(Text_Effect{coord = target.coord, text = fmt.caprintf("%d", amount)})
}

effect_add_status :: proc(actor, target: ^Character, effect: Effect_Add_Status) {
	// chance := (effect.chance / 100)
	status := effect.status
	// TODO: check target resistance function of status
	// TODO: random
	add_status(target, status)
}

effect_add_status_combat :: proc(actor, target: ^Combatant, effect: Effect_Add_Status) {
	// chance := (effect.chance / 100)
	status := effect.status
	// TODO: check target resistance function of status
	// TODO: random
	add_status(target, status)
}

effect_remove_status :: proc(actor, target: ^Character, effect: Effect_Remove_Status) {
	// chance := (effect.chance / 100)
	status := effect.status
	// TODO: check target resistance function of status
	// TODO: random
	remove_status(target, status)
}
effect_remove_status_combat :: proc(actor, target: ^Combatant, effect: Effect_Remove_Status) {
	// chance := (effect.chance / 100)
	status := effect.status
	// TODO: check target resistance function of status
	// TODO: random
	remove_status(target, status)
}

effect_level_up :: proc(_, target: ^Character, effect: Effect_Level_Up) {
	// effect := Effect_Level_Up(effect)
	n := effect.n
	set_level(target, target.level + n)
	// set_skills(target)
}

effect_proc :: proc {
	effect_attack,
	effect_heal_hp,
	effect_heal_hp_combat,
	effect_add_status,
	effect_add_status_combat,
	effect_remove_status,
	effect_remove_status_combat,
	effect_level_up,
}

do_battle_effect :: proc(actor, target: ^Combatant, effect: Effect) {
	#partial switch effect in effect {
	case Effect_Attack:
		effect_proc(actor, target, effect)
	case Effect_Heal_Hp:
		effect_proc(actor, target, effect)
	case Effect_Add_Status:
		effect_proc(actor, target, effect)
	case Effect_Remove_Status:
		effect_proc(actor, target, effect)
	}
}

do_world_effect :: proc(actor, target: ^Character, effect: Effect) {
 #partial switch effect in effect {
 case Effect_Heal_Hp:
	 effect_heal_hp(actor, target, effect)
	case Effect_Add_Status:
		effect_proc(actor, target, effect)
	case Effect_Remove_Status:
		effect_proc(actor, target, effect)
	case Effect_Level_Up:
		effect_proc(actor, target, effect)
 }
}
