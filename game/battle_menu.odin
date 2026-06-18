package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:strings"
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
	w: int,
}
Item_Selection_State :: struct {
	s: int,
	w: int,
}
Target_Selection_State :: struct {
	ts: Target_Selection,
	tt: Targeting_Type,
	// prev: Battle_UI_State,
}
Target_Selection :: union {
	Select_One_Ally,
	Select_One_Baddy,
	Select_All_Allies,
	Select_All_Baddies,
	Select_All_Combatants,
}
Select_One_Baddy :: struct {
	i: int,
}
Select_All_Baddies :: struct {
	prev: int,
}
Select_One_Ally :: struct {
	i: int,
}
Select_All_Allies :: struct {
	prev: int,
}
Select_One_Combatant :: struct {
	i: int,
}
Select_All_Combatants :: struct {}
Targeting_Type :: enum {
	One_Opponent,
	Some_Opponents,
	All_Opponents,
	One_Ally,
	Some_Allies,
	All_Allies,
	One_Combatant,
	All_Combatants,
}
ATTACK :: 0
SKILL :: 1
ITEM :: 2

BATTLE_MENU_SKILLS_ROWS :: 6
BATTLE_MENU_ITEMS_ROWS :: 6

draw_battle_menu :: proc() {
	switch state in battle_ui_state {
	case Action_Selection_State:
		draw_menu(0.0, 10, 4, 4)
		draw_text(0.5, 10.5, "Attack", rl.YELLOW if state.s == 0 else rl.WHITE)
		draw_text(0.5, 11.0, "Skill", rl.YELLOW if state.s == 1 else rl.WHITE)
		draw_text(0.5, 11.5, "Item", rl.YELLOW if state.s == 2 else rl.WHITE)
	case Skill_Selection_State:
		draw_menu(2, 8, 8, BATTLE_MENU_SKILLS_ROWS - 2)
		for r in 0 ..< BATTLE_MENU_SKILLS_ROWS {
			if r >= len(Skill_Name) {break}
			draw_text(
				2.5,
				8.5 + f32(r) * .5,
				// strings.clone_to_cstring(skills[state.s + i].effect, context.temp_allocator),
				fmt.caprint(skills[state.w + r].effect, allocator = context.temp_allocator),
				rl.YELLOW if state.s == state.w + r else rl.WHITE,
			)
		}
	case Item_Selection_State:
		draw_menu(2, 8, 8, BATTLE_MENU_ITEMS_ROWS - 2)
		for r in 0 ..< BATTLE_MENU_ITEMS_ROWS {
			if r >= len(Item_Name) {break}
			draw_text(
				2.5,
				8.5 + f32(r) * .5,
				strings.clone_to_cstring(items[state.w + r].name, context.temp_allocator),
				rl.YELLOW if state.s == state.w + r else rl.WHITE,
			)
		}
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

battle_change_selection :: proc(dx, dy: int) {
	switch &state in battle_ui_state {
	case Action_Selection_State:
		s := state.s
		s += dy
		if s < 0 {s = ITEM}
		if s > ITEM {s = 0}
		battle_ui_state = Action_Selection_State{s}
	case Skill_Selection_State:
		s, w := shift_windowed_selection(dy, state.s, state.w, BATTLE_MENU_SKILLS_ROWS, len(Skill_Name))
		battle_ui_state = Skill_Selection_State{s, w}
	case Item_Selection_State:
		s, w := shift_windowed_selection(dy, state.s, state.w, BATTLE_MENU_ITEMS_ROWS, len(Item_Name))
		battle_ui_state = Item_Selection_State{s, w}
	case Target_Selection_State:
		switch ts in state.ts {
		case Select_One_Baddy:
			if dy != 0 {
				state.ts = Select_One_Baddy{change_baddy_selection(ts.i, dy)}
			} else if dx < 0 && state.tt != .One_Opponent && state.tt != .One_Combatant {
				state.ts = Select_All_Baddies{ts.i}
			} else if dx > 0 && state.tt == .One_Combatant {
				state.ts = Select_One_Ally{}
			}
		case Select_All_Baddies:
			if dx > 0 && state.tt != .All_Opponents {
				state.ts = Select_One_Baddy{ts.prev}
			}
		case Select_One_Ally:
			if dy != 0 {
				state.ts = Select_One_Ally{change_ally_selection(ts.i, dy)}
			} else if dx > 0 && state.tt != .One_Ally && state.tt != .One_Combatant {
				state.ts = Select_All_Allies{ts.i}
			} else if dx < 0 && state.tt == .One_Combatant {
				state.ts = Select_One_Baddy{}
			}
		case Select_All_Allies:
			if dx < 0 && state.tt != .All_Allies {
				state.ts = Select_One_Ally{ts.prev}
			}
		case Select_All_Combatants:
		// do nothing
		}
	}
}

default_target_selection :: proc(tt: Targeting_Type) -> Target_Selection {
	ts: Target_Selection
	switch tt {
	case .One_Opponent:
		ts = Select_One_Baddy{}
	case .Some_Opponents:
		ts = Select_One_Baddy{}
	case .All_Opponents:
		ts = Select_All_Baddies{}
	case .One_Combatant:
		ts = Select_One_Baddy{}
	case .One_Ally:
		ts = Select_One_Ally{}
	case .Some_Allies:
		ts = Select_One_Ally{}
	case .All_Allies:
		ts = Select_All_Allies{}
	case .All_Combatants:
		ts = Select_All_Combatants{}
	}
	return ts
}

// skill_proc: proc(actor, target: ^Combatant)
skill: Skill

pc_turn :: proc(actor: ^Combatant) {
	if battle_ui_state == nil {
		battle_ui_state = Action_Selection_State{}
		return
	}
	if get_input(.UP) {
		battle_change_selection(0, -1)
	} else if get_input(.DOWN) {
		battle_change_selection(0, 1)
	} else if get_input(.LEFT) {
		battle_change_selection(-1, 0)
	} else if get_input(.RIGHT) {
		battle_change_selection(1, 0)
	} else if get_input(.ENTER) {
		switch state in battle_ui_state {
		case Action_Selection_State:
			switch state.s {
			case ATTACK:
				// skill_proc = attack
				skill = skills[Skill_Name.Slash]
				// todo: check weapon target type
				battle_ui_state = Target_Selection_State {
					ts = Select_One_Baddy{select_first_baddy()},
					tt = .One_Opponent,
				}
			case SKILL:
				battle_ui_state = Skill_Selection_State{}
			case ITEM:
				battle_ui_state = Item_Selection_State{}
			}
		case Skill_Selection_State:
			skill = skills[state.s]
			battle_ui_state = Target_Selection_State {
				ts = default_target_selection(skill.targeting),
				tt = skill.targeting,
			}
		case Item_Selection_State:
			if consumable, ok := items[state.s].data.(Consumable); ok {
				skill = skills[consumable]
				battle_ui_state = Target_Selection_State {
					ts = default_target_selection(skill.targeting),
					tt = skill.targeting,
				}
			}
		case Target_Selection_State:
			switch ts in state.ts {
			case Select_One_Baddy:
				if target_cb, ok := hm.get(&battle_combatants, battle_baddy_handles[ts.i]); ok {
					queue_battle_skill(actor, target_cb, skill)
					battle_ui_state = Battle_UI_State{}
					end_turn()
				}
			case Select_All_Baddies:
				for i in 0 ..< MAX_ENCOUNTER_SIZE {
					c := hm.get(&battle_combatants, battle_baddy_handles[i]) or_continue
					if combatant_alive(c) {
						queue_battle_skill(actor, c, skill)
					}
				}
				battle_ui_state = Battle_UI_State{}
				end_turn()
			case Select_One_Ally:
				if target_cb, ok := hm.get(&battle_combatants, battle_pc_handles[ts.i]); ok {
					queue_battle_skill(actor, target_cb, skill)
					battle_ui_state = Battle_UI_State{}
					end_turn()
				}
				battle_ui_state = Battle_UI_State{}
				end_turn()
			case Select_All_Allies:
				for i in 0 ..< NUM_PC {
					c := hm.get(&battle_combatants, battle_pc_handles[i]) or_continue
					if combatant_alive(c) {
						queue_battle_skill(actor, c, skill)
					}
				}
				battle_ui_state = Battle_UI_State{}
				end_turn()
			case Select_All_Combatants:
				it := hm.iterator_make(&battle_combatants)
				for c, _ in hm.iterate(&it) {
					if combatant_alive(c) {
						queue_battle_skill(actor, c, skill)
					}
				}
				battle_ui_state = Battle_UI_State{}
				end_turn()
			}
		}
	} else if get_input(.CANCEL) {
		switch state in battle_ui_state {
		case Action_Selection_State:
		// do nothing
		case Skill_Selection_State:
			battle_ui_state = Action_Selection_State{SKILL}
		case Item_Selection_State:
			battle_ui_state = Action_Selection_State{ITEM}
		case Target_Selection_State:
			battle_ui_state = Action_Selection_State{ATTACK} //fixme
		}
	}
}
