package game

import "core:container/queue"

queue_battle_animation :: proc(event: Play_Animation) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect :: proc(event: Effect_Event) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_sound :: proc(event: Play_Sound) {
	queue.push_back(&battle_event_queue, event)
}

queue_text_effect :: proc(event: Text_Effect) {
	queue.push_back(&battle_event_queue, event)
}
