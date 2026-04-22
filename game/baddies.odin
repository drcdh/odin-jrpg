package game

import "core:fmt"

ATTACK_RANDOM_OPPONENT :: proc(actor_idx: int) {
	actor := battle_combatants[actor_idx].character
	actor_team := battle_combatants[actor_idx].team
	target_idx := get_combatant_not_on_team(actor_team)
	target := get_combatant_ref(target_idx)

	fmt.printfln("> actor %d is attacking target %d %w", actor_idx, target_idx, target)

		queue_battle_animation(
			Battle_Animation{
				draw = draw_expanding_circle,
				offset = Pixel_Coord{100, f32(60+60*target_idx)},
			}
		)

	queue_character_effect(
		Character_Effect {
			character = target,
			effect = HP_LOSS{hp_loss = max(1, actor.stats.offense - target.stats.defense)},
		},
	)

	battle_combatants[actor_idx].t += 20
	end_turn()
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
