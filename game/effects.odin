package game

Effect_F :: proc(actor, target: ^Character, value: int)

effect_heal_hp_constant :: proc(actor, target: ^Character, amount: int) {
	target.hitpoints += amount
}

effect_remove_poison_constant :: proc(actor, target: ^Character, chance: int) {
	// todo: random
	target.poison = false
}

effect_add_poison_constant :: proc(actor, target: ^Character, change: int) {
	// todo: random
	target.poison = true
}
