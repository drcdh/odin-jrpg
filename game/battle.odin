package game

import hm "core:container/handle_map"
import "core:container/queue"
import "core:fmt"
import "core:time"

import rl "vendor:raylib"

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + NUM_PC

battle_active := false
battle_baddies: [MAX_ENCOUNTER_SIZE]Character
battle_baddy_handles: [MAX_ENCOUNTER_SIZE]Combatant_Handle
battle_combatants: hm.Static_Handle_Map(MAX_COMBATANTS, Combatant, Combatant_Handle)
battle_ending := false
battle_event_queue: queue.Queue(Battle_Event)
battle_num_baddies := 0
battle_state: Battle_State

check_win :: proc() -> bool {
	// todo tie function to encounter
	team_alive := [?]bool{false, false}
	it := hm.iterator_make(&battle_combatants)
	for c, _ in hm.iterate(&it) {
		if combatant_alive(c) {
			team_alive[c.team] = true
		}
	}
	if team_alive[0] && !team_alive[1] {
		fmt.println("Team 0 wins")
		battle_ending = true
	} else if !team_alive[0] && team_alive[1] {
		fmt.println("Team 1 wins")
		battle_ending = true
	} else if !team_alive[0] && !team_alive[1] {
		fmt.println("Draw")
		battle_ending = true
	}
	return battle_ending
}

combatant_alive :: proc(c: ^Combatant) -> bool {
	return c.enabled && c.character.stats.hitpoints > 0
}

get_combatant_not_on_team :: proc(actor_team: int) -> ^Combatant {
	// todo: just take first for now
	it := hm.iterator_make(&battle_combatants)
	for c, _ in hm.iterate(&it) {
		if combatant_alive(c) && c.team != actor_team {
			return c
		}
	}
	return nil
}

draw_battle :: proc() {
	rl.DrawRectangleV(Pixel_Coord{50, 50}, Pixel_Dim{800, 800}, TEXT_DISPLAY_BACKGROUND)
	it := hm.iterator_make(&battle_combatants)
	for c, h in hm.iterate(&it) {
		if c.enabled {
			tc := TEXT_COLOR
			if c.character.stats.hitpoints == 0 {
				tc = rl.Color{250, 10, 10, 255}
			}
			if target >= 0 && target < MAX_ENCOUNTER_SIZE && h == battle_baddy_handles[target] {
				tc = rl.Color{50, 100, 100, 255}
			}
			x := i32(c.coord.x)
			y := i32(c.coord.y)
			rl.DrawText(fmt.caprintf("%s HP:%d T:%d", c.character.name, c.character.stats.hitpoints, c.t), x, y, 18, tc)
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

get_next_combatant :: proc() -> Combatant_Handle {
	first := true
	actor_h : Combatant_Handle
	actor_t := 0
	it := hm.iterator_make(&battle_combatants)
	for c, h in hm.iterate(&it) {
		if combatant_alive(c) {
			if first || c.t < actor_t {
				actor_t = c.t
				actor_h = h
				first = false
			}
		}
	}
	return actor_h
}

update_battle :: proc(dt: f32) {
	switch &s in battle_state {
	case Next_Turn:
		if check_win() {
			// todo: enqueue default or encounter-overriding events (exp gain etc.)
			battle_state = Next_Event{}
		} else {
			battle_state = Take_Turn {
				actor_h = get_next_combatant(),
			}
		}
	case Take_Turn:
		// fmt.println(s)
		if actor, ok := hm.get(&battle_combatants, s.actor_h); ok {
			actor.turn(actor)
		} else {
			fmt.println("tried to take turn but handle not in map")
			battle_state = Next_Turn{}
		}
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
				queue.clear(&battle_event_queue)
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

PC_COMBATANT_TURN :: proc(actor: ^Combatant) {
	// fmt.printfln("actor %d target %d", actor_idx, target)
	if target < 0 {target = 0}
	if rl.IsKeyPressed(.UP) {
		change_target(-1)
	} else if rl.IsKeyPressed(.DOWN) {
		change_target(1)
	} else if rl.IsKeyPressed(.SPACE) {
		if target_cb, ok := hm.get(&battle_combatants, battle_baddy_handles[target]); ok {
			queue_battle_animation(
				Battle_Animation{draw = draw_expanding_circle, offset = target_cb.coord},
			)
			queue_character_effect(
				Character_Effect {
					character = target_cb.character,
					effect = HP_LOSS{hp_loss = max(1, actor.character.stats.offense - target_cb.character.stats.defense)},
				},
			)
			target = -1
			actor.t += 20
			end_turn()
		}
	}
}
