package game

import "core:fmt"

Character :: struct {
	name:   cstring,
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
	target := ce.character
	fmt.println("  ~  ", target^, ce.effect)
	switch e in ce.effect {
	case HP_GAIN:
		target.stats.hitpoints += e.hp_gain
	case HP_LOSS:
		target.stats.hitpoints -= e.hp_loss
	case POISON:
		target.status.poison = true
	case nil:
		fmt.println("oops")
	}
}
