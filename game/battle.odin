package game

import "core:container/queue"
import "core:fmt"
import "core:time"

import rl "vendor:raylib"

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + PARTY_SIZE

battle_active := false
battle_combatants := [MAX_COMBATANTS]Combatant{}
battle_ending := false
battle_event_queue: queue.Queue(Battle_Event)
battle_num_combatants := 0
battle_state: Battle_State

check_win :: proc() -> bool {
	// todo tie function to encounter
	team_lives := [?]bool{false, false}
	for bc, i in battle_combatants {
		if bc.enabled && bc.character.stats.hitpoints > 0 {
			team_lives[bc.team] = true
		}
	}
	if team_lives[0] && !team_lives[1] {
		fmt.println("Team 0 wins")
		battle_ending = true
	} else if !team_lives[0] && team_lives[1] {
		fmt.println("Team 1 wins")
		battle_ending = true
	} else if !team_lives[0] && !team_lives[1] {
		fmt.println("Draw")
		battle_ending = true
	}
	return battle_ending
}

draw_battle :: proc() {
	rl.DrawRectangleV(Pixel_Coord{50, 50}, Pixel_Dim{800, 800}, TEXT_DISPLAY_BACKGROUND)
	y := i32(0)
	for bc, i in battle_combatants {
		if bc.enabled {
			y += 60
			tc := TEXT_COLOR
			if bc.character.stats.hitpoints == 0 {
				tc = rl.Color{250, 10, 10, 255}
			}
			if i == target {
				tc = rl.Color{50, 100, 100, 255}
			}
			rl.DrawText(fmt.caprintf("%s HP:%d T:%d", bc.character.name, bc.character.stats.hitpoints, bc.t), 60, y, 18, tc)
		}
	}
	#partial switch s in battle_state {
	case Process_Battle_Animation:
		s.draw(s.t, s.offset)
	}
}

end_turn :: proc() {
	battle_state = Next_Event{}
}

get_next_combatant :: proc() -> int {
	actor_idx := 0
	actor_t := battle_combatants[0].t
	for i in 1 ..< MAX_ENCOUNTER_SIZE {
		if battle_combatants[i].enabled && battle_combatants[i].character.stats.hitpoints > 0 {
			if battle_combatants[i].t < actor_t {
				actor_t = battle_combatants[i].t
				actor_idx = i
			}
		}
	}
	return actor_idx
}

update_battle :: proc(dt: f32) {
	switch &s in battle_state {
	case Next_Turn:
		fmt.println(s)
		if check_win() {
			// todo: enqueue default or encounter-overriding events (exp gain etc.)
			battle_state = Next_Event{}
		} else {
			battle_state = Take_Turn {
				actor_idx = get_next_combatant(),
			}
		}
	case Take_Turn:
		// fmt.println(s)
		actor := &battle_combatants[s.actor_idx]
		actor.turn(s.actor_idx)
	// action, done := actor.turn(actor_idx).?
	case Next_Event:
		if queue.len(battle_event_queue) > 0 {
			switch e in queue.pop_front(&battle_event_queue) {
			case Battle_Animation:
				battle_state = Process_Battle_Animation {
					draw   = e.draw,
					offset = e.offset,
				}
			case Battle_Message:
				// todo
				fmt.println(e.text)
			case Character_Effect:
				do_effect(e)
			}
		} else {
			if battle_ending {
				battle_active = false
			} else {
				battle_state = Next_Turn{}
			}
		}
	case Process_Battle_Animation:
		s.t += dt
		if s.t >= .5 {
			battle_state = Next_Event{}
		}
	}
}

PC_COMBATANT_TURN :: proc(actor_idx: int) {
	// fmt.printfln("actor %d target %d", actor_idx, target)
	if target < 0 {target = 0}
	if rl.IsKeyPressed(.UP) {
		change_target(-1)
	} else if rl.IsKeyPressed(.DOWN) {
		change_target(1)
	} else if rl.IsKeyPressed(.SPACE) {
		target_c := get_combatant_ref(target)
		queue_battle_animation(
			Battle_Animation{draw = draw_expanding_circle, offset = Pixel_Coord{100, f32(60 + 60 * target)}},
		)
		queue_character_effect(
			Character_Effect {
				character = target_c,
				effect = HP_LOSS{hp_loss = max(1, get_combatant_ref(actor_idx).stats.offense - target_c.stats.defense)},
			},
		)
		target = -1
		battle_combatants[actor_idx].t += 20
		end_turn()
	}
}
