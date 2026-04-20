package game

ATTACK_RANDOM_OPPONENT :: proc(actor_idx: int) -> bool {
	actor_team := battle_combatants[actor_idx].team
	target_idx := get_combatant_not_on_team(actor_team)
	action = Battle_Action{ type=BAT_ATTACK, actor=actor_idx, target=target_idx }
	return true
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
