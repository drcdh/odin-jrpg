package game

import "core:container/queue"
import "core:fmt"

attack :: proc(actor, target: ^Combatant) {
	fmt.printfln("> %s is attacking %s", actor.character.name, target.character.name)

	// queue_battle_sound(Battle_Sound{sound = .Whack})
	queue.push_back(&battle_event_queue, Battle_Sound{sound = .Whack})

	queue_battle_animation(Battle_Animation{animation = .Whack, offset = target.coord})

	hp_loss := max(1, actor.character.stats.offense - target.character.stats.defense)

	queue_text_effect(
		Text_Effect{coord = target.coord, text = fmt.caprintf("%d", hp_loss, allocator = context.temp_allocator)},
	)

	queue_character_effect(Character_Effect{character = target.character, effect = HP_LOSS{hp_loss = hp_loss}})

	actor.t += 20
}

ATTACK_RANDOM_OPPONENT :: proc(actor: ^Combatant) {
	actor_team := actor.team
	target := get_combatant_not_on_team(actor_team)

	attack(actor, target)

	end_turn()
}
