package game

ATTACK_RANDOM_OPPONENT :: proc(actor_idx: int) {
	actor := battle.combatants[actor_idx]
	skill = skills[Skill_Name.Bite]
	actor_team := actor.team
	if target, ok := get_combatant_not_on_team(actor_team).?; ok {
		queue_battle_skill(actor_idx, target, skill)
	}
	end_turn()
}
