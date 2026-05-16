package game

attack :: proc(actor, target: ^Combatant) {
	// fmt.printfln("> %s is attacking %s", actor.character.name, target.character.name)

	queue_battle_sound(Play_Sound{sound = .Whack})

	queue_battle_animation(Play_Animation{animation = .Whack, offset = target.coord})

	// queue_text_effect(Text_Effect{coord = target.coord, text = fmt.caprintf("%d", hp_loss)})

	queue_battle_effect(Effect_Event{actor=actor.character, target = target.character, effect_name = .Attack})

	actor.t += 20
}

ATTACK_RANDOM_OPPONENT :: proc(actor: ^Combatant) {
	actor_team := actor.team
	target := get_combatant_not_on_team(actor_team)

	attack(actor, target)

	end_turn()
}
