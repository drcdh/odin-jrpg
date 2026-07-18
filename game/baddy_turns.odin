package game

ATTACK_RANDOM_OPPONENT :: proc(actor_idx: int) {
	skill = skills[Skill_Name.Bite]
	if target, ok := select_one_random_ally().?; ok {
		queue_battle_skill(actor_idx, target, skill)
	}
}
