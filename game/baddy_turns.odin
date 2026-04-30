package game

import "core:fmt"

ATTACK_RANDOM_OPPONENT :: proc(actor: ^Combatant) {
	actor_team := actor.team
	target := get_combatant_not_on_team(actor_team)

	fmt.printfln("> %s is attacking target %s", actor.character.name, target.character.name)

	queue_battle_animation(
		Battle_Animation{draw = draw_expanding_circle, offset = target.coord},
	)

	queue_character_effect(
		Character_Effect {
			character = target.character,
			effect = HP_LOSS{hp_loss = max(1, actor.character.stats.offense - target.character.stats.defense)},
		},
	)

	actor.t += 20

	end_turn()
}

