package game

import hm "core:container/handle_map"
import "core:container/queue"
import "core:fmt"

import rl "vendor:raylib"

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + NUM_PC

battle_active := false
battle_baddies: [MAX_ENCOUNTER_SIZE]Character
battle_baddy_handles: [MAX_ENCOUNTER_SIZE]Combatant_Handle
battle_combatants: hm.Static_Handle_Map(64, Combatant, Combatant_Handle)
battle_pc_handles: [NUM_PC]Combatant_Handle
battle_ending := false
battle_event_queue: queue.Queue(Battle_Event)
battle_num_baddies := 0
battle_num_pc := 0
battle_state: Battle_State

battle_cleanup :: proc() {
	queue.clear(&battle_event_queue)
	hm.clear(&battle_combatants)
}

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
	draw_battle_background()
	draw_battle_party_stats()
	draw_battle_combatants()

	#partial switch s in battle_state {
	case Process_Battle_Animation:
		s.draw(s.t, s.offset)
	case Process_Text_Effect:
		pos := Pixel_Coord{s.coord.x-32, s.coord.y-32*s.t}
		rl.DrawTextEx(font, s.text, pos, 32, 0, rl.Color{0, 0, 0, u8(255*(1-s.t))})
	}
}

draw_battle_background :: proc() {
	rl.ClearBackground(rl.GRAY)
}

remove_margins :: proc(r: rl.Rectangle, p: f32) -> rl.Rectangle {
	return {
		x = r.x + p,
		y = r.y + p,
		width = r.width - 2*p,
		height = r.height - 2*p,
	}
}

draw_battle_party_stats :: proc() {
	draw_menu(rl.Rectangle{0, 24*TILE_SIZE, 32*TILE_SIZE, 4*TILE_SIZE})

	for p in 0..<battle_num_pc {
		draw_party_member_stats(p)
	}
}

draw_battle_combatants :: proc() {
	it := hm.iterator_make(&battle_combatants)
	for c, h in hm.iterate(&it) {
		if c.enabled {
			tc := rl.BLACK
			if c.character.stats.hitpoints <= 0 {
				tc = rl.RED
			}
			if target >= 0 && target < MAX_ENCOUNTER_SIZE && h == battle_baddy_handles[target] {
				r : Pixel_Dim
				switch v in c.visual.variant {
				case Animation:
					r = atlas_textures[v.current_frame].document_size
				case Texture_Name:
					r = atlas_textures[v].document_size
				}
				rl.DrawRectangleV(c.coord-{2,2}, r + {4, 4}, rl.GREEN)
			}
			if actor, ok := battle_state.(Take_Turn); ok {
				if h == actor.actor_h {
					r : Pixel_Dim
					switch v in c.visual.variant {
					case Animation:
						r = atlas_textures[v.current_frame].document_size
					case Texture_Name:
						r = atlas_textures[v].document_size
					}
					rl.DrawRectangleV(c.coord-{2,2}, r + {4, 4}, rl.YELLOW)
				}
			}
			switch v in c.visual.variant {
			case Animation:
				draw_animation(v, c.coord, c.visual.tint)
			case Texture_Name:
				rl.DrawTextureRec(atlas, atlas_textures[v].rect, c.coord, c.visual.tint)
			}
			pos := Pixel_Coord{c.coord.x, c.coord.y-32}
			rl.DrawTextEx(font, c.character.name, pos, 20, 0, tc)
		}
	}
}

draw_party_member_stats :: proc(p: int) {
	if c, ok := hm.get(&battle_combatants, battle_pc_handles[p]); ok {
		tc := TEXT_COLOR
		x := TILE_SIZE
		if p >= 3 {
			x += 14*TILE_SIZE
		}
		y := TILE_SIZE*(25.5 + f32(p % 3))
		if c.character.stats.hitpoints <= 0 {
			tc = rl.RED
		}
		rl.DrawTextEx(font, fmt.caprintf("%s HP:%d T:%d", c.character.name, c.character.stats.hitpoints, c.t), {x, y}, 32, 0, tc)
	}
}

end_turn :: proc() {
	battle_state = Next_Event{}
}

get_next_combatant :: proc() -> Combatant_Handle {
	first := true
	actor_h: Combatant_Handle
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
			case Battle_Sound:
				play_sound(e.sound)
			case Character_Effect:
				do_effect(e)
			case Text_Effect:
				battle_state = Process_Text_Effect {
					coord = e.coord,
					text = e.text,
				}
			}
		} else {
			if battle_ending {
				battle_active = false
				battle_cleanup()
			} else {
				battle_state = Next_Turn{}
			}
		}
	case Process_Battle_Animation:
		s.t += dt
		if s.t >= .5 {
			battle_state = Next_Event{}
		}
	case Process_Text_Effect:
		s.t += dt
		if s.t >= 1 {
			battle_state = Next_Event{}
		}
	}

	it := hm.iterator_make(&battle_combatants)
	for c, _ in hm.iterate(&it) {
		#partial switch &v in c.visual.variant {
		case Animation:
			animation_update(&v, dt)
		}
	}
}

PC_COMBATANT_TURN :: proc(actor: ^Combatant) {
	// fmt.printfln("actor %d target %d", actor_idx, target)
	if target < 0 {target = 0}
	if get_input(.UP) {
		change_target(-1)
	} else if get_input(.DOWN) {
		change_target(1)
	} else if get_input(.ENTER) {
		if target_cb, ok := hm.get(&battle_combatants, battle_baddy_handles[target]); ok {
			attack(actor, target_cb)
			target = -1
			actor.t += 20
			end_turn()
		}
	}
}
