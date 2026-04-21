package game

import "core:fmt"
import "core:time"

import rl "vendor:raylib"

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + PARTY_SIZE

battle_combatants := [MAX_COMBATANTS]Combatant{}
battle_active := false
battle_num_combatants := 0

get_combatant_not_on_team :: proc(actor_team: int) -> int {
	// todo: just take first for now
	for bc, i in battle_combatants {
		if bc.enabled && bc.character.stats.hitpoints > 0 && bc.team != actor_team {
			return i
		}
	}
	return MAX_COMBATANTS // fixme
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
			rl.DrawText(
				fmt.caprintf("%s HP:%d T:%d", bc.character.name, bc.character.stats.hitpoints, bc.t),
				60,
				y,
				18,
				tc,
			)
		}
	}
}

check_win :: proc() {
	// todo tie function to encounter
	team_lives := [?]bool{false, false}
	for bc, i in battle_combatants {
		if bc.enabled && bc.character.stats.hitpoints > 0 {
			team_lives[bc.team] = true
		}
	}
	if team_lives[0] && !team_lives[1] {
		fmt.println("Team 0 wins")
		battle_active = false
	} else if !team_lives[0] && team_lives[1] {
		fmt.println("Team 1 wins")
		battle_active = false
	} else if !team_lives[0] && !team_lives[1] {
		fmt.println("Draw")
		battle_active = false
	}
}

get_next_combatant :: proc() -> int {
	actor_idx := 0
	actor_t := battle_combatants[0].t
	for i in 1..<MAX_ENCOUNTER_SIZE {
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
	// fmt.printfln("%w", battle_combatants)
	actor_idx := get_next_combatant()
	actor := &battle_combatants[actor_idx]
	action, done := actor.turn(actor_idx).?
	if done {
		// time.sleep(time.Second/2)
		target := &battle_combatants[action.target]
		fmt.printfln("%s: actor=%d target=%d", action.type.name, actor_idx, action.target)
		action.type.effect.f(&actor.character.stats, &target.character.stats)
		actor.t += 20
		check_win()
	}
}

target := -1

change_target :: proc(d: int) {
	initial_target := target
	for {
		target += d
		if target < 0 { target = MAX_COMBATANTS - 1 }
		if target >= MAX_COMBATANTS { target = 0 }
		if target == initial_target { return }
		if battle_combatants[target].enabled { return }
	}
}

PC_COMBATANT_TURN :: proc(actor_idx: int) -> Maybe(Battle_Action) {
	// fmt.printfln("actor %d target %d", actor_idx, target)
	if target < 0 { target = 0 }
	if rl.IsKeyPressed(.UP) {
		change_target(-1)
	} else if rl.IsKeyPressed(.DOWN) {
		change_target(1)
	} else if rl.IsKeyPressed(.SPACE) {
		return Battle_Action{ type=BAT_ATTACK, actor=actor_idx, target=target }
	}
	return nil
}
