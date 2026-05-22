package game

Effect_Proc :: proc(actor, target: ^Character, value: int)

Effect_Name :: enum {
	Attack,
	Heal_Hp_Constant,
	Remove_Poison,
	Add_Poison,
	Fire,
}

effect_attack :: proc(actor, target: ^Character, v: int) {
	hp_loss := max(1, actor.offense - target.defense)
	target.hitpoints -= hp_loss
}

effect_heal_hp_constant :: proc(actor, target: ^Character, amount: int) {
	target.hitpoints += amount
}

effect_remove_poison :: proc(actor, target: ^Character, chance: int) {
	// todo: random
	target.poison = false
}

effect_add_poison :: proc(actor, target: ^Character, chance: int) {
	// todo: random
	target.poison = true
}

effect_fire_damage :: proc(actor, target: ^Character, power: int) {
	hp_loss := max(0, power * actor.pOffense - target.pDefense)
	target.hitpoints -= hp_loss
}

do_hp_change :: proc(target: ^Character, amount: int) {
	// if combatant := get_combatant(target.id); combatant != nil {
	// 	queue_text_effect(Text_Effect{coord = combatant.coord, text = fmt.caprintf("%d", hp_loss)})
	// }
	target.hitpoints += amount
}

do_effect :: proc(e: Effect_Name, actor, target: ^Character, v: int) {
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
	f(actor, target, v)
}
