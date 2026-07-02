package game

import "core:fmt"
import rl "vendor:raylib"

// Effect_Proc :: proc(actor, target: ^Combatant, effect: Effect)

Effect_Name :: enum {
	Attack,
	Heal_Hp,
	Add_Status,
	Remove_Status,
	Level_Up,
}

Effect_Attack :: struct {
	constant:   int,
	power:      int,
	psy_power:  int,
	pierce:     int,
	psy_pierce: int,
	accuracy:   int,
	risk:       int,
	// traits
	ranged:     bool,
}

Effect_Heal_Hp :: struct {
	constant: int,
	power:    int,
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

effect_attack :: proc(actor, target: ^Character, effect: Effect_Attack) {
	constant := f16(effect.constant)
	power := f16(effect.power) / 100
	pierce := f16(effect.pierce) / 100
	psy_power := f16(effect.psy_power) / 100
	psy_pierce := f16(effect.psy_pierce) / 100
	risk := f32(effect.risk) / 100
	offense := f16(actor.offense)
	defense := f16(target.defense)
	psy_offense := f16(actor.psy_offense)
	psy_defense := f16(target.psy_defense)
	hp_loss_f :=
		constant +
		max(0, power * offense - (1 - pierce) * defense) +
		max(0, psy_power * psy_offense - (1 - psy_pierce) * psy_defense)
	fmt.printfln("%s -> %s: %v", actor.name, target.name, effect)
	fmt.printfln(
		"  hp_loss = %d + max(0, %.2f*%d - %.2f*%d) + max(0, %.2f*%d - %.2f*%d)",
		effect.constant,
		power,
		actor.offense,
		(1 - pierce),
		target.defense,
		psy_power,
		actor.psy_offense,
		(1 - psy_pierce),
		target.psy_defense,
	)
	hp_loss := int(hp_loss_f)
	fmt.printfln("  hp_loss = %f = %d", hp_loss_f, hp_loss)
	target.hitpoints -= hp_loss
	queue_text_effect_character(target, fmt.caprintf("%d", hp_loss))
	roll_for_counter(target, actor, risk)
}

effect_heal_hp :: proc(actor, target: ^Character, effect: Effect_Heal_Hp) {
	power := (effect.power / 100)
	hp_gain := effect.constant
	if power > 0 {
		hp_gain += power * actor.psy_offense
	}
	hp_gain = max(0, hp_gain)
	target.hitpoints = min(target.hitpoints + hp_gain, target.max_hitpoints) // TODO: put this everywhere
	queue_text_effect_character(target, fmt.caprintf("%d", hp_gain), rl.GREEN)
}

effect_add_status :: proc(actor, target: ^Character, effect: Effect_Add_Status) {
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

effect_level_up :: proc(_, target: ^Character, effect: Effect_Level_Up) {
	// effect := Effect_Level_Up(effect)
	n := effect.n
	set_level(target, target.level + n)
	// set_skills(target)
	queue_text_effect_character(target, fmt.caprintf("%d", n), rl.PURPLE)
}

effect_proc :: proc {
	effect_attack,
	effect_heal_hp,
	effect_add_status,
	effect_remove_status,
	effect_level_up,
}

do_effect :: proc(actor, target: ^Character, effect: Effect) {
	switch effect in effect {
	case Effect_Attack:
		effect_proc(actor, target, effect)
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
