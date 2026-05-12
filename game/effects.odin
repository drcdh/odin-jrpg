package game

Effect_F ::  proc(actor: ^Stats, target: ^Stats, power: int)

effect_heal_hp_constant :: proc(actor: ^Stats, target: ^Stats, power: int) {
	target.hitpoints += power
}
