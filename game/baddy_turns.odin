package game

ATTACK_RANDOM_OPPONENT :: proc(actor: ^Combatant) {
	skill = skills[Skill_Name.Bite]
	actor_team := actor.team
	target := get_combatant_not_on_team(actor_team)

	queue_battle_skill(actor, target, skill)

	end_turn()
}
