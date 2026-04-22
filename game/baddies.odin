package game

ATTACK_RANDOM_OPPONENT :: proc(actor_idx: int) {
	actor := battle_combatants[actor_idx].character
	actor_team := battle_combatants[actor_idx].team
	target_idx := get_combatant_not_on_team(actor_team)
	target := battle_combatants[target_idx].character

	queue_character_effect(
		Character_Effect {
			character = &target,
			effect = HP_LOSS{hp_loss = max(1, actor.stats.offense - target.stats.defense)},
		},
	)
	// return Battle_Action{type = BAT_ATTACK, actor = actor_idx, target = target_idx}
}

new_mouse_sized_rat :: proc() -> Combatant {
	return Combatant {
		character = Character{stats = Stats{hitpoints = 1, offense = 1, defense = 1}, name = "Mouse-Sized Rat"},
		enabled = true,
		t = 10,
		turn = ATTACK_RANDOM_OPPONENT,
	}}

new_rat_sized_mouse :: proc() -> Combatant {
	return Combatant {
		character = Character{stats = Stats{hitpoints = 3, offense = 3, defense = 2}, name = "Rat-Sized Mouse"},
		enabled = true,
		t = 12,
		turn = ATTACK_RANDOM_OPPONENT,
	}}
