package game

Character :: struct {
	name:   string,
	stats:  Stats,
	status: Status,
}

Status :: struct {
	poison: bool,
	zombie: bool,
}


HP_GAIN :: struct {
	hp_gain: int,
}
HP_LOSS :: struct {
	hp_loss: int,
}
POISON :: struct {}

Character_Effect_Variant :: union {
	HP_GAIN,
	HP_LOSS,
	POISON,
}

Character_Effect :: struct {
	character: ^Character,
	effect:    Character_Effect_Variant,
}

do_effect :: proc(ce: Character_Effect) {
	switch e in ce.effect {
	case HP_GAIN:
		ce.character.stats.hitpoints += e.hp_gain
	case HP_LOSS:
		ce.character.stats.hitpoints -= e.hp_loss
	case POISON:
		ce.character.status.poison = true
	}
}
