#+feature using-stmt
package game

import "core:fmt"
import "core:math"
import "core:slice"

import rl "vendor:raylib"

BATTLE_SPEED :: 1 // ticks per second

READY_T :: 100 // ticks per turn

TAKE_TURN_DELAY :: .5 // seconds

Battle :: struct {
	active:      bool,
	allies:      [dynamic]int,
	animations:  [dynamic]Process_Battle_Animation,
	baddies:     [dynamic]int,
	combatants:  [dynamic]Combatant,
	encounter:   int,
	ending:      bool,
	menu_skills: [dynamic]Skill_Name,
	paused:      bool,
	skill_plays: [dynamic]Battle_Skill_Play,
	skill_state: Process_Skill,
	sounds:      [dynamic]Play_Sound,
	state:       Battle_State,
	text:        [dynamic]Process_Text_Effect,
}

battle: Battle

targeting_ease: f32

battle_cleanup :: proc() {
	clear(&battle.combatants)
	clear(&battle.skill_plays)
}

battle_destroy :: proc() {
	delete(battle.combatants)
	delete(battle.skill_plays)
}

battle_init :: proc() {
}

check_win :: proc() -> bool {
	// TODO: tie function to encounter
	team_alive := [?]bool{false, false}
	for c in battle.combatants {
		if combatant_alive(c) {
			team_alive[c.team] = true
		}
	}
	if team_alive[0] && !team_alive[1] {
		fmt.println("Team 0 wins")
		battle.ending = true
	} else if !team_alive[0] && team_alive[1] {
		fmt.println("Team 1 wins")
		battle.ending = true
	} else if !team_alive[0] && !team_alive[1] {
		fmt.println("Draw")
		battle.ending = true
	}
	return battle.ending
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

select_one_random_ally :: proc() -> Maybe(Select_One_Ally) {
	// TODO: just take first for now
	for c_idx, ally_idx in battle.allies {
		if combatant_alive(battle.combatants[c_idx]) {
			return Select_One_Ally{ally_idx}
		}
	}
	return nil
}

draw_battle :: proc() {
	draw_battle_background()
	draw_battle_party_stats()
	draw_battle_menu()
	draw_battle_combatants()

	for s in battle.animations {
		draw_animation(s.animation, s.offset)
	}

	for s in battle.text {
		pos := Pixel_Coord{s.coord.x - 32, s.coord.y - 32 * s.t}
		rl.DrawTextEx(font, s.text, pos, 32, 0, rl.Color{s.color.x, s.color.y, s.color.z, u8(255 * (1 - s.t))})
	}

	// debug
	// rl.DrawText(fmt.caprint(battle_ui_state, allocator = context.temp_allocator), 0, i32(7 * tile_size), 16, rl.BLACK)
	// rl.DrawText(fmt.caprint(battle.state, allocator = context.temp_allocator), 0, i32(7.5 * tile_size), 16, rl.BLACK)
}

draw_battle_background :: proc() {
	draw_texture(battle_background, {})
}

draw_battle_party_stats :: proc() {
	draw_menu(4, VIEW_TILES_H - 4, VIEW_TILES_W - 4, 4)

	for i, p in battle.allies {
		c := battle.combatants[i]
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

draw_battle_combatants :: proc() {
	for c, c_idx in battle.combatants {
		if c.enabled {
			tint := c.visual.tint
			if c.character.hitpoints <= 0 {
				tint = rl.RED
			}
			if turn, ok := battle.state.(Take_Turn); ok {
				if c_idx == turn.c_idx {
					tint = rl.GREEN
				}
			}
			if targeted(c_idx, c.team) {
				tint = rl.YELLOW
				tint.w = u8(targeting_ease * 255)
			}
			switch v in c.visual.variant {
			case Animation:
				draw_animation(v, c.coord, tint)
			case Texture_Name:
				draw_texture(v, c.coord, tint)
			}
			// debug
			draw_text(
				c.coord.x / tile_size,
				c.coord.y / tile_size,
				fmt.caprintf("%d", abs(c.t), allocator = context.temp_allocator),
				rl.WHITE if c.t >= 0 else rl.ORANGE,
			)
		}
	}
}

end_turn :: proc() {
	battle.state = Next_Turn{}
}

battle_time_tick :: proc(dt: f32) {
	for &s, i in battle.skill_plays {
		s.windup -= int(math.sqrt(get_stat_f(battle.combatants[s.actor].character, .Speed)))
		if s.windup <= 0 {
			battle.skill_state = Process_Skill{active=true, skill_plays_idx=i}
		}
	}

	for &c in battle.combatants {
		if !c.enabled {continue}
		if combatant_downed(c) {continue}
		if combatant_winding_up(c) {continue}
		c.t += BATTLE_SPEED * int(math.sqrt(f32(c.character.speed)))
	}
}

get_ready_combatant :: proc() -> (lead: int, ready := false) {
	lead_t := 0
	for c, i in battle.combatants {
		if !c.enabled {continue}
		if combatant_downed(c) {continue}
		if combatant_winding_up(c) {continue}
		if c.t >= lead_t {
			lead = i
			lead_t = c.t
		}
	}
	if lead_t >= READY_T {
		ready = true
	}
	return
}

// get_ready_skill :: proc() -> (int, bool) {
// 	for s, i in battle.skill_plays {
// 		if s.windup <= 0 {
// 			return i, true
// 		}
// 	}
// 	return 0, false
// }

get_next_combatant :: proc() -> int {
	first := true
	actor_idx: int
	actor_t := 0
	for c, i in battle.combatants {
		if combatant_alive(c) {
			if first || c.t < actor_t {
				actor_t = c.t
				actor_idx = i
				first = false
			}
		}
	}
	return actor_idx
}

update_battle :: proc(dt: f32) {
	if !battle.paused {
		if !battle.skill_state.active {
			battle_time_tick(dt)
		}
		process_ready_battle_skill(dt)
		process_ready_combatants(dt)
	}

	targeting_ease += dt / .5
	if targeting_ease > 1 {targeting_ease = 0}

	for anim_idx := 0; anim_idx < len(battle.animations); {
		if animation_update(&battle.animations[anim_idx].animation, dt) {
			unordered_remove(&battle.animations, anim_idx)
		} else {
			anim_idx += 1
		}
	}

	for sound_idx := 0; sound_idx < len(battle.sounds); {
		sp := battle.sounds[sound_idx]
		// TODO delay
		play_sound(sp.sound)
		unordered_remove(&battle.sounds, sound_idx)
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

	if battle.ending {
		battle.active = false
		battle_cleanup()
	}
}

// process_battle_state :: proc(dt: f32) {
// 	switch &s in battle.state {
// 	case Next_Turn:
// 		if check_win() {
// 			// TODO: run default or encounter-overriding procedure (exp gain etc.)
// 			// battle.state = Aftermath{}
// 		} else if skill_idx, skill_ready := get_ready_skill(); skill_ready {
// 			battle.state = Process_Skill {
// 				skill_idx = skill_idx,
// 			}
// 		} else if c_idx, c_ready := get_ready_combatant(); c_ready {
// 			battle.state = Take_Turn {
// 				c_idx = c_idx,
// 			}
// 		} else {
// 		}
// 	case Take_Turn:
// 		s.t += dt
// 		if s.t >= TAKE_TURN_DELAY {
// 			battle.combatants[s.c_idx].turn(s.c_idx)
// 		}
// 	case Process_Skill:
// 		if process_battle_skill() {
// 			unordered_remove(&battle.skill_plays, s.skill_idx)
// 			battle.state = Next_Turn{}
// 		}
// 	}
// }

blah :: proc(animation_name: Animation_Name, sound: Sound_Name, target_idx: int) {
	r := center_animation_on_combatant(animation_name, battle.combatants[target_idx])
	append(
		&battle.animations,
		Process_Battle_Animation{animation = animation_create(animation_name), offset = {r.x, r.y}},
	)
	append(&battle.sounds, Play_Sound{sound = sound})
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
	for combatant, c_idx in battle.combatants {
		if combatant.t >= READY_T {
			combatant.turn(c_idx)
		}
	}
}

process_battle_skill :: proc() -> (done := false) {
	// fmt.printfln("% 4d: processing battle skill step %d", frame_count, skill_state.step)
	// fmt.printfln("%#v", battle.animations)
	// fmt.printfln("%#v", battle.sounds)
	// fmt.printfln("%#v", battle.text)
	using battle
	play := skill_plays[skill_state.skill_plays_idx]
	skill := play.skill
	switch skill_state.step {
	case 0:
		// TODO: set_text_display(skill.name)
		skill_state.step += 1
	case 1:
		if skill_state.t += rl.GetFrameTime(); skill_state.t >= .5 {
			skill_state.t = 0
			skill_state.step += 1
		}
	case 2:
		// TODO: set actor to walk left
		skill_state.step += 1
	case 3:
		// TODO: wait for walk to finish
		skill_state.step += 1
	case 4:
		if skill_state.t += rl.GetFrameTime(); skill_state.t >= .5 {
			skill_state.t = 0
			skill_state.step += 1
		}
	case 5:
		animation_name := Animation_Name.Ffvi_Stars if skill.animation == nil else skill.animation
		sound := Sound_Name.Whack if skill.sound == nil else skill.sound
		switch targets in play.targets {
		case Select_One_Ally:
			blah(animation_name, sound, battle.allies[targets.i])
		case Select_One_Baddy:
			blah(animation_name, sound, battle.baddies[targets.i])
		case Select_All_Allies:
			for target_idx in battle.allies {
				blah(animation_name, sound, target_idx)
			}
		case Select_All_Baddies:
			for target_idx in battle.baddies {
				blah(animation_name, sound, target_idx)
			}
		case Select_All_Combatants:
			for _, target_idx in battle.combatants {
				blah(animation_name, sound, target_idx)
			}
		}
		skill_state.step += 1
	case 6:
		if len(battle.animations) == 0 && len(battle.sounds) == 0 {
			skill_state.step += 1
		}
	case 7:
		actor := battle.combatants[play.actor]
		switch targets in play.targets {
		case Select_One_Ally:
			target := battle.combatants[battle.allies[targets.i]]
			do_effect(&actor, &target, skill.effect)
		case Select_One_Baddy:
			target := battle.combatants[battle.baddies[targets.i]]
			do_effect(&actor, &target, skill.effect)
		case Select_All_Allies:
			for target_idx in battle.allies {
				target := battle.combatants[target_idx]
				do_effect(&actor, &target, skill.effect)
			}
		case Select_All_Baddies:
			for target_idx in battle.baddies {
				target := battle.combatants[target_idx]
				do_effect(&actor, &target, skill.effect)
			}
		case Select_All_Combatants:
			for &target in battle.combatants {
				do_effect(&actor, &target, skill.effect)
			}
		}
		skill_state.step += 1
	case 8:
		if len(battle.text) == 0 {
			skill_state.step += 1
		}
	case 9:
		// TODO: set actor to walk right
		skill_state.step += 1
	case 10:
		// TODO: wait for walk to finish then set actor to idle left
		// TODO: remove_text_display(skill.name)
		done = true
	}
	return
}

targeted :: proc(c_idx, team: int) -> bool {
	if tss, ok := battle_ui_state.(Target_Selection_State); ok {
		switch ts in tss.ts {
		case Select_One_Baddy:
			return team == BADDY_TEAM && c_idx == ts.i
		case Select_One_Ally:
			return team == PLAYER_TEAM && c_idx == ts.i
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

set_battle_skills :: proc(actor: ^Character) {
	clear(&battle.menu_skills)
	for s in 0 ..< len(skills) {
		if Skill_Name(s) in actor.skills {
			append(&battle.menu_skills, Skill_Name(s))
		}
	}
}

roll_for_counter :: proc(actor, target: ^Character, risk: f32 = 1) {
}
