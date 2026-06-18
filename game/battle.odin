package game

import hm "core:container/handle_map"
import "core:container/queue"
import "core:fmt"
import "core:slice"

import rl "vendor:raylib"

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + NUM_PC

READY_T :: 100

TAKE_TURN_DELAY :: .5 // seconds

battle_active := false
battle_baddies: [MAX_ENCOUNTER_SIZE]Character
battle_baddy_handles: [MAX_ENCOUNTER_SIZE]Combatant_Handle
battle_combatants: hm.Static_Handle_Map(64, Combatant, Combatant_Handle)
battle_pc_handles: [NUM_PC]Combatant_Handle
battle_ending := false
battle_event_queue: queue.Queue(Battle_Event)
battle_num_baddies := 0
battle_num_pc := 0
battle_paused := false
battle_skills: [dynamic]Battle_Skill_Play
battle_state: Battle_State
battle_turn_order: [dynamic]Battle_Turn_Order

targeting_ease: f32

battle_cleanup :: proc() {
	queue.clear(&battle_event_queue)
	hm.clear(&battle_combatants)
	delete(battle_skills)
	delete(battle_turn_order)
}

battle_destroy :: proc() {
	queue.destroy(&battle_event_queue)
}

battle_init :: proc() {
	battle_skills = make([dynamic]Battle_Skill_Play, 0, MAX_COMBATANTS)
	battle_turn_order = make([dynamic]Battle_Turn_Order, 0, MAX_COMBATANTS)
	it := hm.iterator_make(&battle_combatants)
	for _, h in hm.iterate(&it) {
		append(&battle_turn_order, Battle_Turn_Order{h = h})
	}
	calc_turn_order()
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
	return c.enabled && c.character.hitpoints > 0
}

combatant_downed :: proc(c: ^Combatant) -> bool {
	return c.enabled && c.character.hitpoints <= 0
}

combatant_winding_up :: proc(c: ^Combatant) -> bool {
	return c.enabled && c.windup
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
	draw_battle_menu()
	draw_battle_combatants()
	draw_battle_turn_order()

	#partial switch s in battle_state {
	case Process_Battle_Animation:
		draw_animation(s.animation, s.offset, rl.WHITE)
	case Process_Text_Effect:
		pos := Pixel_Coord{s.coord.x - 32, s.coord.y - 32 * s.t}
		rl.DrawTextEx(font, s.text, pos, 32, 0, rl.Color{0, 0, 0, u8(255 * (1 - s.t))})
	}

	// debug
	rl.DrawText(fmt.caprint(battle_ui_state, allocator = context.temp_allocator), 0, i32(7 * tile_size), 16, rl.BLACK)
	rl.DrawText(fmt.caprint(battle_state, allocator = context.temp_allocator), 0, i32(7.5 * tile_size), 16, rl.BLACK)
}

draw_battle_background :: proc() {
	// rl.ClearBackground(rl.GRAY)
	draw_texture(battle_background, {})
}

remove_margins :: proc(r: rl.Rectangle, p: f32) -> rl.Rectangle {
	return {x = r.x + p, y = r.y + p, width = r.width - 2 * p, height = r.height - 2 * p}
}

draw_battle_party_stats :: proc() {
	draw_menu(4, VIEW_TILES_H - 4, VIEW_TILES_W - 4, 4)

	for p in 0 ..< battle_num_pc {
		draw_party_member_stats(p)
	}
}

draw_battle_combatants :: proc() {
	it := hm.iterator_make(&battle_combatants)
	for c, h in hm.iterate(&it) {
		if c.enabled {
			tint := c.visual.tint
			if c.character.hitpoints <= 0 {
				tint = rl.RED
			}
			if targeted(c.id, c.team) {
				tint = rl.YELLOW
				tint.w = u8(targeting_ease * 255)
			}
			if actor, ok := battle_state.(Take_Turn); ok {
				if h == actor.actor_h {
					tint = rl.GREEN
				}
			}
			switch v in c.visual.variant {
			case Animation:
				draw_animation(v, c.coord, tint)
			case Texture_Name:
				draw_texture(v, c.coord, tint)
			}
			// debug
			draw_text(c.coord.x / tile_size, c.coord.y / tile_size, fmt.caprintf("%d", c.t), rl.ORANGE)
		}
	}
}

draw_party_member_stats :: proc(p: int) {
	if c, ok := hm.get(&battle_combatants, battle_pc_handles[p]); ok {
		text_color := rl.WHITE
		if c.character.hitpoints <= 0 {
			text_color = rl.RED
		}
		draw_text(
			4.5,
			(VIEW_TILES_H - 3.5) + f32(p) / 2,
			fmt.caprintf(
				"%- 13s% 4d/% 4d",
				c.character.name,
				c.character.hitpoints,
				c.character.max_hitpoints,
				allocator = context.temp_allocator,
			),
			text_color,
		)
	}
}

draw_battle_turn_order :: proc() {
	i := 0
	for o in battle_turn_order {
		c := hm.get(&battle_combatants, o.h)
		if !combatant_alive(c) {continue}
		t: Texture_Name
		switch v in c.visual.variant {
		case Animation:
			t = v.current_frame
		case Texture_Name:
			t = v
		}
		i += 1
		rl.DrawRectangle(i32(5 + i) * i32(tile_size), 0, i32(tile_size), i32(tile_size), rl.BLACK)
		draw_texture_chunk(t, tile_to_pixel(5 + i, 0), rl.GRAY if o.staged else rl.WHITE)
	}
}

turn_order_not_staged :: proc(o: Battle_Turn_Order) -> bool {
	return !o.staged
}

clear_staged_turn_order :: proc() {
	battle_turn_order = slice.into_dynamic(slice.filter(battle_turn_order[:], turn_order_not_staged))
}

end_turn :: proc() {
	battle_state = Next_Event{}
}

battle_time_tick :: proc() {
	for &s in battle_skills {
		s.windup -= s.actor.speed
	}

	it := hm.iterator_make(&battle_combatants)
	for c, _ in hm.iterate(&it) {
		if !c.enabled {continue}
		if combatant_downed(c) {continue}
		if combatant_winding_up(c) {continue}
		c.t += c.character.speed
	}

	calc_turn_order()
}

get_ready_combatant :: proc() -> (lead: Combatant_Handle, ready := false) {
	lead_t := 0
	it := hm.iterator_make(&battle_combatants)
	for c, h in hm.iterate(&it) {
		if !c.enabled {continue}
		if combatant_downed(c) {continue}
		if combatant_winding_up(c) {continue}
		if c.t >= lead_t {
			lead = h
			lead_t = c.t
		}
	}
	if lead_t >= READY_T {
		ready = true
	}
	return
}

get_ready_skill :: proc() -> (int, bool) {
	for s, i in battle_skills {
		if s.windup <= 0 {
			return i, true
		}
	}
	return 0, false
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

turn_order_cmp :: proc(lhs, rhs: Battle_Turn_Order) -> bool {
	c_lhs := hm.get(&battle_combatants, lhs.h)
	c_rhs := hm.get(&battle_combatants, rhs.h)
	return c_lhs.t > c_rhs.t // this is backward on purpose
}

calc_turn_order :: proc() {
	slice.sort_by(battle_turn_order[:], turn_order_cmp)
}

update_battle :: proc(dt: f32) {
	targeting_ease += dt / .5
	if targeting_ease > 1 {targeting_ease = 0}

	if !battle_paused {
		process_battle_events(dt)
	}

	it := hm.iterator_make(&battle_combatants)
	for c, _ in hm.iterate(&it) {
		#partial switch &v in c.visual.variant {
		case Animation:
			animation_update(&v, dt)
		}
	}
}

process_battle_events :: proc(dt: f32) {
	switch &s in battle_state {
	case Next_Turn:
		if check_win() {
			// todo: enqueue default or encounter-overriding events (exp gain etc.)
			battle_state = Next_Event{}
		} else if i, skill_ready := get_ready_skill(); skill_ready {
			queue_battle_skill_events(battle_skills[i])
			unordered_remove(&battle_skills, i)
			battle_state = Next_Event{}
		} else if c, c_ready := get_ready_combatant(); c_ready {
			battle_state = Take_Turn {
				actor_h = c,
			}
		} else {
			battle_time_tick()
		}
	case Take_Turn:
		s.t += dt
		if s.t >= TAKE_TURN_DELAY {
			if actor, ok := hm.get(&battle_combatants, s.actor_h); ok {
				actor.turn(actor)
			} else {
				fmt.println("tried to take turn but handle not in map")
				battle_state = Next_Turn{}
			}
		}
	case Next_Event:
		if queue.len(battle_event_queue) > 0 {
			switch e in queue.pop_front(&battle_event_queue) {
			case Battle_Effect_Event:
				do_battle_effect(e.effect_name, e.actor, e.target, e.value)
			case Play_Animation:
				battle_state = Process_Battle_Animation {
					animation = animation_create(e.animation),
					offset    = e.offset,
				}
			case Play_Sound:
				play_sound(e.sound)
			case Text_Effect:
				battle_state = Process_Text_Effect {
					coord = e.coord,
					text  = e.text,
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
		if animation_update(&s.animation, dt) {
			battle_state = Next_Event{}
		}
	case Process_Text_Effect:
		s.t += dt
		if s.t >= 1 {
			delete(s.text)
			battle_state = Next_Event{}
		}
	}
}

targeted :: proc(id, team: int) -> bool {
	if tss, ok := battle_ui_state.(Target_Selection_State); ok {
		switch ts in tss.ts {
		case Select_One_Baddy:
			return team == BADDY_TEAM && id == ts.i
		case Select_One_Ally:
			return team == PLAYER_TEAM && id == ts.i
		case Select_All_Allies:
			return team == PLAYER_TEAM
		case Select_All_Baddies:
			return team == BADDY_TEAM
		case Select_All_Combatants:
			return true
		}
	}
	return false
}
