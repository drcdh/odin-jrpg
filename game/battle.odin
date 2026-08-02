package game

import "core:fmt"
import "core:math"

import rl "vendor:raylib"

BATTLE_SPEED :: 2 // ticks per second per speed

READY_T :: 100 // ticks per turn

TAKE_TURN_DELAY :: .5 // seconds

MULTI_TARGET_DELAY :: .2 // seconds

Battle :: struct {
	active:      bool,
	allies:      [dynamic]int,
	animations:  [dynamic]Process_Battle_Animation,
	baddies:     [dynamic]int,
	combatants:  [dynamic]Combatant,
	encounter:   ^Encounter,
	paused:      bool,
	skill_plays: [dynamic]Battle_Skill_Play,
	skill_state: Process_Skill,
	sounds:      [dynamic]Play_Sound,
	text:        [dynamic]Process_Text_Effect,
}

battle: Battle

targeting_ease: f32

battle_cleanup :: proc() {
	for c_idx in battle.baddies {
		// free new Characters created with new_baddy in start_encounter
		free(battle.combatants[c_idx].character)
	}
	clear(&battle.allies)
	clear(&battle.animations)
	clear(&battle.baddies)
	clear(&battle.combatants)
	clear(&battle.skill_plays)
	clear(&battle.sounds)
	clear(&battle.text)
	battle.skill_state = Process_Skill{}
}

battle_deactivate :: proc() {
	battle.active = false
	battle_cleanup()
}

battle_destroy :: proc() {
	delete(battle.allies)
	delete(battle.animations)
	delete(battle.baddies)
	delete(battle.combatants)
	delete(battle.skill_plays)
	delete(battle.sounds)
	delete(battle.text)
}

battle_init :: proc() {
	battle_menu_start()
	init_events :=
		battle.encounter.init_events.? or_else []Event{Curtain_Up{.Battle}, Pause_Runner{.5}, Battle_Unpause{}, End{}}
	queue_events(init_events, battle = true)
}

check_win :: proc() -> Maybe(Battle_Result) {
	allies_alive := false
	for c_idx in battle.allies {
		if combatant_alive(battle.combatants[c_idx]) {
			allies_alive = true
		}}
	if !allies_alive {
		return .Lose
	}
	baddies_alive := false
	for c_idx in battle.baddies {
		if combatant_alive(battle.combatants[c_idx]) {
			baddies_alive = true
		}
	}
	if !baddies_alive {
		return .Win
	}
	return nil
}

combatant_ready :: proc(c: Combatant) -> bool {
	return c.t >= READY_T && combatant_alive(c) && !combatant_winding_up(c)
}

combatant_alive :: proc(c: Combatant) -> bool {
	return c.enabled && c.character.hitpoints > 0
}

combatant_downed :: proc(c: Combatant) -> bool {
	return c.enabled && c.character.hitpoints <= 0
}

combatant_winding_up :: proc(c: Combatant) -> bool {
	return c.enabled && c.windup
}

get_combatant :: proc(character: ^Character) -> ^Combatant {
	for &c in battle.combatants {
		if c.character == character {
			return &c
		}
	}
	return nil
}

get_combatant_skill_play :: proc(c_idx: int) -> Maybe(int) {
	for sp, i in battle.skill_plays {
		if sp.actor == c_idx {
			return i
		}
	}
	return nil
}

get_combatant_coord :: proc(c: Combatant) -> Pixel_Coord {
	return c.coord + Pixel_Coord{f32(-math.sign(1 - 2 * c.team)), 1} * c.coord_d
}

select_one_random_ally :: proc() -> Maybe(Target_One_Ally) {
	// TODO: just take first for now
	for c_idx, ally_idx in battle.allies {
		if combatant_alive(battle.combatants[c_idx]) {
			return Target_One_Ally{ally_idx}
		}
	}
	return nil
}

draw_battle :: proc() {
	draw_battle_background()
	battle_menu_draw()
	draw_battle_combatants()

	for s in battle.animations {
		if s.delay <= 0 {
			draw_animation(s.animation, s.offset)
		}
	}

	for s in battle.text {
		pos := Pixel_Coord{s.coord.x - 32, s.coord.y - 32 * s.t}
		rl.DrawTextEx(font, s.text, pos, 32, 0, rl.Color{s.color.x, s.color.y, s.color.z, u8(255 * (1 - s.t))})
	}

	// debug
	// rl.DrawText(fmt.ctprint(battle_ui_state), 0, i32(7 * tile_size), 16, rl.BLACK)
	// rl.DrawText(fmt.ctprint(battle.state), 0, i32(7.5 * tile_size), 16, rl.BLACK)
}

draw_battle_background :: proc() {
	draw_texture(battle_background, {})
}

draw_battle_combatants :: proc() {
	for c, c_idx in battle.combatants {
		if c.enabled {
			tint := c.visual.tint
			if c.character.hitpoints <= 0 {
				tint = rl.ColorTint(tint, rl.RED)
			}
			c_coord := get_combatant_coord(c)
			if battle_menu.ui_state != .Idle {
				if c_idx == battle_menu.ui_data.c_idx {
					draw_animation(select_tile_icon_down, c_coord + {0, -tile_size})
				}
			}
			if targeted(c_idx, c.team) {
				draw_animation(select_tile_icon, c_coord + {-tile_size, 0})
			}
			switch v in c.visual.variant {
			case Animation:
				draw_animation(v, c_coord, tint)
			case Texture_Name:
				draw_texture(v, c_coord, tint)
			}
			// debug
			draw_text(
				c.coord.x / tile_size,
				c.coord.y / tile_size,
				fmt.ctprintf("%.0f", abs(c.t)),
				rl.WHITE if c.t >= 0 else rl.ORANGE,
			)
			if skill_play_idx, ok := get_combatant_skill_play(c_idx).?; ok {
				draw_text(
					c.coord.x / tile_size,
					.5 + c.coord.y / tile_size,
					fmt.ctprintf("%.0f", battle.skill_plays[skill_play_idx].windup),
					rl.ORANGE,
				)
			}
		}
	}
}

battle_time_tick :: proc(dt: f32) {
	ticks := dt * BATTLE_SPEED
	for &s, i in battle.skill_plays {
		s.windup -= ticks * get_stat_f(battle.combatants[s.actor].character, .Speed)
		if s.windup <= 0 {
			s.windup = 0
			battle.skill_state = Process_Skill {
				active          = true,
				skill_plays_idx = i,
			}
		}
	}

	for &c in battle.combatants {
		if !c.enabled {continue}
		if combatant_downed(c) {continue}
		if combatant_winding_up(c) {continue}
		c.t += ticks * get_stat_f(c.character, .Speed)
		if c.t > READY_T {c.t = READY_T}
		if true {
			skill_set_charge_tick(&c.character.skills)
			if battle_menu.ui_state == .Skills {
				battle_menu_set_stale(.Skills)
			}
		}
	}
}

get_next_ready_pc :: proc() -> Maybe(int) {
	for c_idx, a_idx in battle.allies {
		if combatant_ready(battle.combatants[c_idx]) {
			return a_idx
		}
	}
	// FIXME: infinite loop somehow?
	// current: int
	// if ally_idx, ally_ready := battle.pc_ready.?; ally_ready {
	// 	current = ally_idx
	// } else {
	// 	current = 0
	// }
	// for next := current + 1; next != current; next += 1 {
	// 	if next >= len(battle.allies) {
	// 		next = 0
	// 	}
	// 	if combatant_ready(battle.combatants[battle.allies[next]]) {
	// 		return next
	// 	}
	// }
	// if combatant_ready(battle.combatants[battle.allies[current]]) {
	// 	return current
	// }
	return nil
}

update_battle :: proc(dt: f32) {
	if !battle.paused {
		switch check_win() {
		case nil:
			if !battle.skill_state.active {
				battle_time_tick(dt)
			}
			process_ready_battle_skill(dt)
			process_ready_combatants(dt)
			check_downed_baddies()
			battle_menu_update()
		case .Lose:
			battle.paused = true
			lose_events := battle.encounter.lose_events.? or_else []Event {
					Append_Text_Ex{text = "You lost|", hurry = true, pause = 1, lines = 2},
					Close_Dialogue{},
					Clear_Text{},
					Pause_Runner{.5},
					Curtain_Down{.Battle},
					// TODO: clear other runners
					Battle_Deactivate{},
					// TODO: Title{},
					End{},
				}
			queue_events(lose_events, battle = true)
		case .Win:
			battle.paused = true
			// TODO: set party members to cheer pose
			runner_idx := party_get_experience(battle.encounter.exp)
			win_events := battle.encounter.win_events.? or_else []Event {
					Add_Item{.Potion, 1},
					Append_Text_Ex{text = fmt.aprintf("Got item: %v", Item_Name.Potion), hurry = true, pause = 1, lines = 2}, // FIXME: leak
					Close_Dialogue{},
					Clear_Text{},
					Pause_Runner{.5},
					Curtain_Down{.Battle},
					Battle_Deactivate{},
					End{},
				}
			queue_events(win_events, battle = true, i = runner_idx)
		}
	}

	targeting_ease += dt / .5
	if targeting_ease > 1 {targeting_ease = 0}

	for anim_idx := 0; anim_idx < len(battle.animations); {
		battle.animations[anim_idx].delay -= dt
		if battle.animations[anim_idx].delay <= 0 && animation_update(&battle.animations[anim_idx].animation, dt) {
			unordered_remove(&battle.animations, anim_idx)
		} else {
			anim_idx += 1
		}
	}

	for sound_idx := 0; sound_idx < len(battle.sounds); {
		battle.sounds[sound_idx].delay -= dt
		if battle.sounds[sound_idx].delay <= 0 {
			play_sound(battle.sounds[sound_idx].sound)
			unordered_remove(&battle.sounds, sound_idx)
		} else {
			sound_idx += 1
		}
	}

	for text_idx := 0; text_idx < len(battle.text); {
		battle.text[text_idx].t += dt
		if battle.text[text_idx].t >= 1 {
			delete(battle.text[text_idx].text)
			unordered_remove(&battle.text, text_idx)
		} else {
			text_idx += 1
		}
	}

	for c in battle.combatants {
		#partial switch &v in c.visual.variant {
		case Animation:
			animation_update(&v, dt)
		}
	}
}

play_anim_sound :: proc(animation_name: Animation_Name, sound: Sound_Name, target_idx: int, delay: f32 = 0) {
	r := center_animation_on_combatant(animation_name, battle.combatants[target_idx])
	append(
		&battle.animations,
		Process_Battle_Animation{animation = animation_create(animation_name), offset = {r.x, r.y}, delay = delay},
	)
	append(&battle.sounds, Play_Sound{sound = sound, delay = delay})
}

process_ready_battle_skill :: proc(dt: f32) {
	if battle.skill_state.active {
		if process_battle_skill() {
			unordered_remove(&battle.skill_plays, battle.skill_state.skill_plays_idx)
			battle.skill_state.active = false
		}
	}
}

process_ready_combatants :: proc(dt: f32) {
	if battle_menu.ui_state == .Idle {
		if ally_idx, ready := get_next_ready_pc().?; ready {
			battle_menu.ui_data.c_idx = battle.allies[ally_idx]
			battle_menu.ui_state = .Top
		}
	}
	for combatant, c_idx in battle.combatants {
		if combatant.t >= READY_T {
			// check for confusion, etc. of PCs
			if combatant.turn != nil {
				combatant.turn(c_idx)
			}
		}
	}
}

check_downed_baddies :: proc() {
	// check for downed baddies, fade them, and disable
	runner_idx: Maybe(int)
	for c_idx in battle.baddies {
		c := battle.combatants[c_idx]
		if c.enabled && c.hitpoints <= 0 {
			if runner_idx == nil {
				runner_idx = queue_events(
					[]Event{Battle_Pause{}, Pause_Runner{.5}, Play_Sound{sound = .Down}, Combatant_Transition{c_idx}},
					battle = true,
				)
			} else {
				runner_idx = queue_events(
					[]Event{Pause_Runner{.25}, Play_Sound{sound = .Down}, Combatant_Transition{c_idx}},
					i = runner_idx,
				)
			}
		}
	}
	if runner_idx != nil {
		queue_events([]Event{Pause_Runner{.5}, Battle_Unpause{}}, i = runner_idx)
	}
}

combatant_transition :: proc(c_idx: int) -> bool {
	dt := rl.GetFrameTime()
	c := battle.combatants[c_idx]
	alpha := c.visual.tint.a
	if alpha == 0 {
		battle.combatants[c_idx].enabled = false
		battle_menu_set_stale(.Baddies)
		return true // finished
	} else {
		// reduce alpha
		da := u8(dt * 600)
		if alpha <= da {
			alpha = 0
		} else {
			alpha -= da
		}
		battle.combatants[c_idx].visual.tint.a = alpha
	}
	return false
}

process_battle_skill :: proc() -> (done := false) {
	// fmt.printfln("% 4d: processing battle skill step %d", frame_count, skill_state.step)
	// fmt.printfln("%#v", battle.animations)
	// fmt.printfln("%#v", battle.sounds)
	// fmt.printfln("%#v", battle.text)
	play := battle.skill_plays[battle.skill_state.skill_plays_idx]
	skill := play.skill
	switch battle.skill_state.step {
	case 0:
		// TODO: set_text_display(skill.name)
		fmt.printfln("~~ %s ~~", skill.name)
		battle.skill_state.step += 1
	case 1:
		if battle.skill_state.t += rl.GetFrameTime(); battle.skill_state.t >= .5 {
			battle.skill_state.t = 0
			battle.skill_state.step += 1
		}
	case 2:
		// TODO: set actor pose to walk left
		battle.skill_state.step += 1
	case 3:
		if battle.combatants[play.actor].coord_d.x > -tile_size {
			battle.combatants[play.actor].coord_d.x -= 4 * rl.GetFrameTime() * tile_size
		} else {
			battle.combatants[play.actor].coord_d.x = -tile_size
			// TODO: freeze actor animation to 2nd frame
			battle.skill_state.step += 1
		}
	case 4:
		if battle.skill_state.t += rl.GetFrameTime(); battle.skill_state.t >= .5 {
			battle.skill_state.t = 0
			battle.skill_state.step += 1
		}
	case 5:
		animation_name := Animation_Name.Ffvi_Stars if skill.animation == nil else skill.animation
		sound := Sound_Name.Whack if skill.sound == nil else skill.sound
		switch targets in play.targets {
		case Target_One_Ally:
			play_anim_sound(animation_name, sound, battle.allies[targets.i])
		case Target_One_Baddy:
			play_anim_sound(animation_name, sound, battle.baddies[targets.i])
		case Target_All_Allies:
			for target_idx, i in battle.allies {
				play_anim_sound(animation_name, sound, target_idx, delay = f32(i) * MULTI_TARGET_DELAY)
			}
		case Target_All_Baddies:
			for target_idx, i in battle.baddies {
				play_anim_sound(animation_name, sound, target_idx, delay = f32(i) * MULTI_TARGET_DELAY)
			}
		case Target_All_Combatants:
			for _, target_idx in battle.combatants {
				play_anim_sound(animation_name, sound, target_idx, delay = f32(target_idx) * MULTI_TARGET_DELAY)
			}
		}
		battle.skill_state.step += 1
	case 6:
		if len(battle.animations) == 0 && len(battle.sounds) == 0 {
			battle.skill_state.step += 1
		}
	case 7:
		actor := battle.combatants[play.actor]
		switch targets in play.targets {
		case Target_One_Ally:
			target := battle.combatants[battle.allies[targets.i]]
			do_effect(&actor, &target, skill.effect)
		case Target_One_Baddy:
			target := battle.combatants[battle.baddies[targets.i]]
			do_effect(&actor, &target, skill.effect)
		case Target_All_Allies:
			for target_idx in battle.allies {
				target := battle.combatants[target_idx]
				do_effect(&actor, &target, skill.effect)
			}
		case Target_All_Baddies:
			for target_idx in battle.baddies {
				target := battle.combatants[target_idx]
				do_effect(&actor, &target, skill.effect)
			}
		case Target_All_Combatants:
			for &target in battle.combatants {
				do_effect(&actor, &target, skill.effect)
			}
		}
		battle_menu_set_stale(.Baddies)
		battle_menu_set_stale(.Party)
		battle.skill_state.step += 1
	case 8:
		if len(battle.text) == 0 {
			battle.skill_state.step += 1
		}
	case 9:
		// TODO: set actor to walk right
		battle.skill_state.step += 1
	case 10:
		if battle.combatants[play.actor].coord_d.x < 0 {
			battle.combatants[play.actor].coord_d.x += 4 * rl.GetFrameTime() * tile_size
		} else {
			battle.combatants[play.actor].coord_d.x = 0
			// TODO: wait for walk to finish then set actor to idle left
			// TODO: remove_text_display(skill.name)
			done = true
		}
	}
	return
}

targeted :: proc(c_idx, team: int) -> bool {
	if battle_menu.ui_state == .Skill_Target || battle_menu.ui_state == .Item_Target {
		switch ts in battle_menu.ui_data.targets {
		case Target_One_Baddy:
			return team == BADDY_TEAM && c_idx == battle.baddies[ts.i]
		case Target_One_Ally:
			return team == PLAYER_TEAM && c_idx == battle.allies[ts.i]
		case Target_All_Allies:
			return team == PLAYER_TEAM
		case Target_All_Baddies:
			return team == BADDY_TEAM
		case Target_All_Combatants:
			return true
		}
	}
	return false
}

roll_for_counter :: proc(actor, target: ^Character, risk: f32 = 1) {
}
