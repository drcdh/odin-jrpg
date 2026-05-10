package game

import hm "core:container/handle_map"
import rl "vendor:raylib"

battle_ui_state: Battle_UI_State

Battle_UI_State :: union {
	Action_Selection_State, // attack, skills, item, etc. indicated but not selected
	Skill_Selection_State, // skill indicated but not selected
	Item_Selection_State, // item indicated but not selected
	Target_Selection_State, // targeting a combatant to attack
}
Action_Selection_State :: struct {
	s: int,
}
Skill_Selection_State :: struct {
	s: int,
}
Item_Selection_State :: struct {
	s: int,
}
Target_Selection_State :: struct {
	ts: Target_Selection,
	tt: Targeting_Type,
	// prev: Battle_UI_State,
}
Target_Selection :: union {
	Select_Baddy,
	Select_All_Baddies,
	Select_Ally,
	Select_All_Allies,
	Select_All_Combatants,
}
Select_Baddy :: struct {
	i: int,
}
Select_All_Baddies :: struct {
	prev: int,
}
Select_Ally :: struct {
	i: int,
}
Select_All_Allies :: struct {
	prev: int,
}
Select_All_Combatants :: struct {}
Targeting_Type :: enum {
	One_Opponent,
	Some_Opponents,
	All_Opponents,
	One_Ally,
	Some_Allies,
	All_Allies,
	All_Combatants,
}
ATTACK :: 0
SKILL :: 1
ITEM :: 2

draw_battle_menu :: proc() {
	switch state in battle_ui_state {
	case Action_Selection_State:
		draw_menu(VIEW_TILES_W / 2 - VIEW_TILES_W / 4, VIEW_TILES_H - 4, VIEW_TILES_W / 4, 4)
		x: f32 = tile_size * (VIEW_TILES_W / 2 - VIEW_TILES_W / 4 + .5)
		y := tile_size * (VIEW_TILES_H - 3.5)
		rl.DrawTextEx(font, "Attack", {x, y}, tile_size / 2, 0, TEXT_COLOR)
		rl.DrawTextEx(font, "Skill", {x, y + tile_size / 2}, tile_size / 2, 0, TEXT_COLOR)
		rl.DrawTextEx(font, "Item", {x, y + tile_size}, tile_size / 2, 0, TEXT_COLOR)
		rl.DrawRectangleLinesEx({x, y + f32(state.s) * tile_size / 2, 100, tile_size / 2}, 2, rl.ORANGE)
	case Skill_Selection_State:
	case Item_Selection_State:
	case Target_Selection_State:
	}
}

change_ally_selection :: proc(t, d: int) -> int {
	// todo: check party membership
	target := t + d
	if target < 0 {target = NUM_PC - 1}
	if target >= NUM_PC {target = 0}
	return target
}

change_baddy_selection :: proc(t, d: int) -> int {
	initial_target := t
	target := t + d
	for {
		if target < 0 {target = MAX_ENCOUNTER_SIZE - 1}
		if target >= MAX_ENCOUNTER_SIZE {target = 0}
		if target == initial_target {break}
		if c, ok := hm.get(&battle_combatants, battle_baddy_handles[target]); ok {
			if c.enabled {break}
		}
		target += d
	}
	return target
	// targeting_ease = 0
}

select_first_baddy :: proc() -> int {
	return change_baddy_selection(MAX_ENCOUNTER_SIZE, 1)
}

change_selection :: proc(dx, dy: int) {
	switch &state in battle_ui_state {
	case Action_Selection_State:
		s := state.s
		s += dy
		if s < 0 {s = ITEM}
		if s > ITEM {s = 0}
		battle_ui_state = Action_Selection_State{s}
	case Skill_Selection_State:
	case Item_Selection_State:
	case Target_Selection_State:
		switch ts in state.ts {
		case Select_Baddy:
			if dy != 0 {
				state.ts = Select_Baddy{change_baddy_selection(ts.i, dy)}
			} else if dx < 0 {
				state.ts = Select_All_Baddies{ts.i}
			} else if dx > 0 {
				state.ts = Select_Ally{}
			}
		case Select_All_Baddies:
			if dx > 0 {
				state.ts = Select_Baddy{ts.prev}
			}
		case Select_Ally:
			if dy != 0 {
				state.ts = Select_Ally{change_ally_selection(ts.i, dy)}
			} else if dx > 0 {
				state.ts = Select_All_Allies{ts.i}
			} else if dx < 0 {
				state.ts = Select_Baddy{}
			}
		case Select_All_Allies:
			if dx < 0 {
				state.ts = Select_Ally{ts.prev}
			}
		case Select_All_Combatants:
		// do nothing
		}
	}
}

skill_proc: proc(actor, target: ^Combatant)

pc_turn :: proc(actor: ^Combatant) {
	if battle_ui_state == nil {
		battle_ui_state = Action_Selection_State{}
		return
	}
	if get_input(.UP) {
		change_selection(0, -1)
	} else if get_input(.DOWN) {
		change_selection(0, 1)
	} else if get_input(.LEFT) {
		change_selection(-1, 0)
	} else if get_input(.RIGHT) {
		change_selection(1, 0)
	} else if get_input(.ENTER) {
		switch state in battle_ui_state {
		case Action_Selection_State:
			switch state.s {
			case ATTACK:
				skill_proc = attack
				// todo: check weapon target type
				battle_ui_state = Target_Selection_State {
					ts = Select_Baddy{select_first_baddy()},
					tt = .One_Opponent,
				}
			case SKILL:
			case ITEM:
			}
		case Skill_Selection_State:
		case Item_Selection_State:
		case Target_Selection_State:
			switch ts in state.ts {
			case Select_Baddy:
				if target_cb, ok := hm.get(&battle_combatants, battle_baddy_handles[ts.i]); ok {
					skill_proc(actor, target_cb)
					battle_ui_state = Battle_UI_State{}
					actor.t += 20
					end_turn()
				}
			case Select_All_Baddies:
			case Select_Ally:
			case Select_All_Allies:
			case Select_All_Combatants:
			}
		}
	}
}
