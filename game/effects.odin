package game

import "core:fmt"

// TODO, maybe: implement Effect_Result
Effect_Proc :: proc(actor, target: ^Character, value: int) -> (int, bool)

Effect_Name :: enum {
	Attack,
	Heal_Hp_Constant,
	Remove_Poison,
	Add_Poison,
	Fire,
}

effect_attack :: proc(actor, target: ^Character, v: int) -> (int, bool) {
	hp_change := -max(1, actor.offense - target.defense)
	target.hitpoints += hp_change
	return hp_change, true
}

effect_heal_hp_constant :: proc(actor, target: ^Character, amount: int) -> (int, bool) {
	target.hitpoints += amount
	return amount, true
}

effect_remove_poison :: proc(actor, target: ^Character, chance: int) -> (int, bool) {
	// todo: random
	target.poison = false
	return 0, false
}

effect_add_poison :: proc(actor, target: ^Character, chance: int) -> (int, bool) {
	// todo: random
	target.poison = true
	return 0, false
}

effect_fire_damage :: proc(actor, target: ^Character, power: int) -> (int, bool) {
	hp_change := -max(0, power * actor.pOffense - target.pDefense)
	target.hitpoints += hp_change
	return hp_change, true
}

do_effect :: proc(e: Effect_Name, actor, target: ^Character, v: int) -> (int, bool) {
	f: Effect_Proc
	switch e {
	case .Attack:
		f = effect_attack
	case .Heal_Hp_Constant:
		f = effect_heal_hp_constant
	case .Remove_Poison:
		f = effect_remove_poison
	case .Add_Poison:
		f = effect_add_poison
	case .Fire:
		f = effect_fire_damage
	}
	return f(actor, target, v)
}

do_battle_effect :: proc(e: Effect_Name, actor, target: ^Combatant, v: int) {
	if amount, hp_changed := do_effect(e, actor.character, target.character, v); hp_changed {
		queue_text_effect(Text_Effect{coord = target.coord, text = fmt.caprintf("%d", amount)})
	}
}
