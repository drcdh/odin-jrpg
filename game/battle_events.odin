package game

queue_battle_animation :: proc(a: Battle_Animation) {
	battle_event_queue[battle_event_queue_len] = a
	battle_event_queue_len += 1
}

queue_battle_message :: proc(m: Battle_Message) {
	battle_event_queue[battle_event_queue_len] = m
	battle_event_queue_len += 1
}

queue_character_effect :: proc(ce: Character_Effect) {
	battle_event_queue[battle_event_queue_len] = ce
	battle_event_queue_len += 1
	// switch ce in Character_Interaction.character_effect {
	// case .HP_GAIN:
	// 	// enqueue animation
	// 	tce.target.hitpoints = min(tce.target.hitpoints_max, tce.target.hitpoints + ce.hp_gain)
	// case .HP_LOSS:
	// 	// enqueue animation
	// 	tce.target.hitpoints = max(0, tce.target.hitpoints - ce.hp_gain)
	// // case .POISON:
	// }
}
