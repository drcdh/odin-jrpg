package game

import "core:container/queue"

queue_battle_animation :: proc(event: Play_Animation) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect_ee :: proc(event: Effect_Event) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect_aten :: proc(effect_name: Effect_Name, actor, target: ^Character, power: int) {
	queue_battle_effect_ee(Effect_Event{effect_name, actor, target, power})
}

queue_battle_effect :: proc {
	queue_battle_effect_aten,
	queue_battle_effect_ee,
}

queue_battle_sound :: proc(event: Play_Sound) {
	queue.push_back(&battle_event_queue, event)
}

queue_text_effect :: proc(event: Text_Effect) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_skill :: proc(actor, target: ^Combatant, skill: Skill) {
	animation := Animation_Name.Ffvi_Stars if skill.animation == nil else skill.animation
	sound := Sound_Name.Whack if skill.sound == nil else skill.sound

	queue_battle_sound(Play_Sound{sound = sound})
	queue_battle_animation(Play_Animation { animation = animation, offset = target.coord })
	queue_battle_effect(skill.effect, actor.character, target.character, skill.power)
}
