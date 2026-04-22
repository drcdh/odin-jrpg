package game

import "core:container/queue"

queue_battle_animation :: proc(event: Battle_Animation) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_message :: proc(event: Battle_Message) {
	queue.push_back(&battle_event_queue, event)
}

queue_character_effect :: proc(event: Character_Effect) {
	queue.push_back(&battle_event_queue, event)
}
