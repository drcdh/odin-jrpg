package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Battle_UI_Top_Choices :: enum {
	Skill,
	Item,
	Equip,
	Run,
}

Battle_UI_Data :: struct {
	c_idx:     int,
	top:       Battle_UI_Top_Choices,
	skill_sel: Selection,
	inv_sel:   Selection,
	skill:     Skill_Name,
	targets:   Target_Selection,
}

Battle_UI_State :: enum {
	Inactive,
	Idle,
	Top,
	Skills,
	Skill_Target,
	Inventory,
	Item_Target,
	//Equipment, // choose a slot
	//Equipment_Swap // choose an equippable
}

Battle_Pane :: enum {
	Text,
	Baddies,
	Party,
	Top,
	Skills,
	Inventory,
}

BATTLE_PANE_ORIGIN := [BATTLE_MENU_NUM_TEXTURES]Tile_Coord {
	{0, 0},
	{0, VIEW_TILES_H - 4},
	{4, VIEW_TILES_H - 4},
	{1, VIEW_TILES_H - 4},
	{3, VIEW_TILES_H - 4},
	{3, VIEW_TILES_H - 4},
}

BATTLE_PANE_DIM := [BATTLE_MENU_NUM_TEXTURES][2]int {
	{VIEW_TILES_W, 2},
	{4, 4},
	{VIEW_TILES_W - 4, 4},
	{4, 4},
	{VIEW_TILES_W - 8, int(BATTLE_MENU_SKILLS_ROWS / 2) + 1},
	{VIEW_TILES_W - 8, int(BATTLE_MENU_INVENTORY_ROWS / 2) + 1},
}

// battle_pane_redraw_proc := map[Battle_Pane]proc(){
// 	.Top = battle_redraw_top_pane,
// 	.Baddies = battle_redraw_baddies_pane,
// 	.Party = battle_redraw_party_pane,
// 	.Skills = battle_redraw_skills_pane,
// 	.Inventory = battle_redraw_inventory_pane,
// }

BATTLE_MENU_NUM_TEXTURES :: len(Battle_Pane)

Battle_Menu :: struct {
	stale:    [BATTLE_MENU_NUM_TEXTURES]bool,
	textures: [BATTLE_MENU_NUM_TEXTURES]rl.RenderTexture,
	ui_data:  Battle_UI_Data,
	ui_state: Battle_UI_State,
}

BATTLE_MENU_SKILLS_ROWS :: 6
BATTLE_MENU_INVENTORY_ROWS :: 6

battle_menu: Battle_Menu

battle_menu_load :: proc() {
	for pane in Battle_Pane {
		dim := BATTLE_PANE_DIM[pane]
		battle_menu.textures[pane] = rl.LoadRenderTexture(i32(dim.x) * i32(tile_size), i32(dim.y) * i32(tile_size))
	}
}

battle_menu_unload :: proc() {
	for t in battle_menu.textures {
		rl.UnloadRenderTexture(t)
	}
}

battle_menu_start :: proc() {
	battle_menu.ui_data = Battle_UI_Data{}
	battle_menu.ui_state = .Idle

	for pane in Battle_Pane {
		battle_redraw_pane(pane)
	}
}

battle_menu_end :: proc() {
	battle_menu.ui_state = .Inactive
}

battle_menu_draw :: proc() {
	for &stale, i in battle_menu.stale {
		if stale {
			battle_redraw_pane(Battle_Pane(i))
			stale = false
		}
	}
	switch battle_menu.ui_state {
	case .Inactive:
	case .Idle:
		battle_draw_panes(.Baddies, .Party)
	case .Top:
		battle_draw_panes(.Baddies, .Party, .Top)
	case .Skills:
		battle_draw_panes(.Baddies, .Party, .Top, .Skills)
	case .Skill_Target:
		battle_draw_panes(.Baddies, .Party, .Top, .Skills)
	case .Inventory:
		battle_draw_panes(.Baddies, .Party, .Top, .Inventory)
	case .Item_Target:
		battle_draw_panes(.Baddies, .Party, .Top, .Inventory)
	//case .Equipment:
	//case .Equipment_Swap:
	}
	battle_menu_draw_icons()
}

battle_menu_draw_icons :: proc() {
	switch battle_menu.ui_state {
	case .Inactive:
	case .Idle:
	case .Top:
		battle_draw_top_icons()
	case .Skills:
		battle_draw_skills_icons()
	case .Skill_Target:
	case .Inventory:
		battle_draw_inventory_icons()
	case .Item_Target:
	}
}

battle_redraw_top_pane :: proc() {
	draw_text(0.5, 0.5, "Skill", rl.YELLOW if battle_menu.ui_data.top == Battle_UI_Top_Choices.Skill else rl.WHITE)
	draw_text(0.5, 1.0, "Item ", rl.YELLOW if battle_menu.ui_data.top == Battle_UI_Top_Choices.Item else rl.WHITE)
	draw_text(0.5, 1.5, "Equip", rl.YELLOW if battle_menu.ui_data.top == Battle_UI_Top_Choices.Equip else rl.WHITE)
	draw_text(0.5, 2.0, "Run  ", rl.YELLOW if battle_menu.ui_data.top == Battle_UI_Top_Choices.Run else rl.WHITE)
}

battle_draw_top_icons :: proc() {
	draw_animation(
		world_menu_icon,
		tile_to_pixel(BATTLE_PANE_ORIGIN[Battle_Pane.Top]) + tile_to_pixel(.5, .75 + .5 * f32(battle_menu.ui_data.top)),
	)
}

battle_redraw_baddies_pane :: proc() {}

battle_redraw_party_pane :: proc() {
	for i, p in battle.allies {
		c := battle.combatants[i]
		tint := rl.WHITE
		if c.character.hitpoints <= 0 {
			tint = rl.RED
		}
		draw_text(
			.5,
			.5 + f32(p) / 2,
			fmt.ctprintf("%- 13s% 4d/% 4d", c.character.name, c.character.hitpoints, c.character.max_hitpoints),
			tint,
		)
	}
}


battle_redraw_skills_pane :: proc() {
	c_skills := get_character_skills(battle.combatants[battle_menu.ui_data.c_idx].character.skills)
	// fmt.printfln("\n%#v\n", c_skills)
	for r in 0 ..< BATTLE_MENU_SKILLS_ROWS {
		if r >= len(c_skills) {break}
		cs := c_skills[battle_menu.ui_data.skill_sel.origin_idx + r]
		tint := rl.WHITE
		if r == selection_row(battle_menu.ui_data.skill_sel) {
			tint = rl.YELLOW
		}
		if cs.charge < CHARGE_MAX {
			tint = rl.GRAY
		}
		draw_text(
			.5,
			.5 + f32(r) * .5,
			fmt.ctprintf("%s % 3.0f", skills[cs.skill_name].name, 100 * f16(cs.charge) / CHARGE_MAX),
			tint,
		)
	}
}

battle_draw_skills_icons :: proc() {
	draw_animation(
		world_menu_icon,
		tile_to_pixel(BATTLE_PANE_ORIGIN[Battle_Pane.Skills]) +
		tile_to_pixel(0., .5 + .5 * selection_row_f(battle_menu.ui_data.skill_sel)),
	)
}

battle_redraw_inventory_pane :: proc() {
	for r in 0 ..< BATTLE_MENU_INVENTORY_ROWS {
		if r >= len(Item_Name) {break}
		draw_text(
			.5,
			.5 + f32(r) * .5,
			strings.clone_to_cstring(
				items[inventory_order[battle_menu.ui_data.inv_sel.origin_idx + r]].name,
				context.temp_allocator,
			),
			rl.YELLOW if r == selection_row(battle_menu.ui_data.inv_sel) else rl.WHITE,
		)
	}
}

battle_draw_inventory_icons :: proc() {
	draw_animation(
		world_menu_icon,
		tile_to_pixel(BATTLE_PANE_ORIGIN[Battle_Pane.Inventory]) +
		tile_to_pixel(0., .5 + .5 * selection_row_f(battle_menu.ui_data.inv_sel)),
	)
}

battle_redraw_pane :: proc(pane: Battle_Pane) {
	fmt.printfln("Redrawing texture for %w", pane)
	rl.BeginTextureMode(battle_menu.textures[pane])
	draw_pane(BATTLE_PANE_DIM[pane])
	// battle_pane_redraw_proc[pane]()
	switch pane {
	case .Text:
	// special?
	case .Baddies:
		battle_redraw_baddies_pane()
	case .Party:
		battle_redraw_party_pane()
	case .Top:
		battle_redraw_top_pane()
	case .Skills:
		battle_redraw_skills_pane()
	case .Inventory:
		battle_redraw_inventory_pane()
	}
	rl.EndTextureMode()
}

battle_draw_pane :: proc(pane: Battle_Pane) {
	origin_tile := BATTLE_PANE_ORIGIN[pane]
	origin := tile_to_pixel(origin_tile)
	texture := battle_menu.textures[pane].texture
	w := f32(texture.width)
	h := f32(texture.height)
	dest := rl.Rectangle{origin.x, origin.y, w, -h}
	rl.DrawTexturePro(texture, {0, 0, w, -h}, dest, {}, 0, rl.WHITE)
}

battle_draw_panes :: proc(panes: ..Battle_Pane) {
	for pane in panes {
		battle_draw_pane(pane)
	}
}

battle_menu_set_stale :: proc(pane: Battle_Pane) {
	battle_menu.stale[pane] = true
}

battle_menu_update :: proc() {
	switch battle_menu.ui_state {
	case .Inactive:
	case .Idle:

	case .Top:
		if get_input(.ENTER) {
			switch battle_menu.ui_data.top {
			case .Skill:
				battle_menu.ui_state = .Skills
				battle_menu_set_stale(.Skills)
			case .Item:
				battle_menu.ui_data.inv_sel = Selection{}
				battle_menu.ui_state = .Inventory
				battle_menu_set_stale(.Inventory)
			case .Equip:
			case .Run:
			}
		} else if get_input(.MENU) {
			// TODO: change ready character
		} else if dy, ok := get_y_input().?; ok {
			battle_menu.ui_data.top = Battle_UI_Top_Choices(
				grid_change(int(battle_menu.ui_data.top), 0, dy, 1, len(Battle_UI_Top_Choices)),
			)
			battle_menu_set_stale(.Top)
		}

	case .Skills:
		if get_input(.ENTER) {
			battle_menu.ui_data.skill =
				get_character_skills(battle.combatants[battle_menu.ui_data.c_idx].character.skills)[battle_menu.ui_data.skill_sel.row_idx].skill_name
			if battle.combatants[battle_menu.ui_data.c_idx].character.skills.charges[battle_menu.ui_data.skill] ==
			   CHARGE_MAX {
				battle_menu.ui_state = .Skill_Target
				battle_menu.ui_data.targets = default_target_selection(skills[battle_menu.ui_data.skill].targeting)
			}
		} else if get_input(.CANCEL) {
			battle_menu.ui_state = .Top
		} else if dy, ok := get_y_input().?; ok {
			c_skills := get_character_skills(battle.combatants[battle_menu.ui_data.c_idx].character.skills)
			fmt.printfln("\n%#v\n", c_skills)
			battle_menu.ui_data.skill_sel = shift_windowed_selection(
				dy,
				battle_menu.ui_data.skill_sel,
				BATTLE_MENU_SKILLS_ROWS,
				len(c_skills),
			)
			battle_menu_set_stale(.Skills)
		}

	case .Skill_Target:
		if get_input(.ENTER) {
			battle.combatants[battle_menu.ui_data.c_idx].character.skills.charges[battle_menu.ui_data.skill] = 0
			queue_battle_skill(battle_menu.ui_data.c_idx, battle_menu.ui_data.targets, skills[battle_menu.ui_data.skill])
			battle_menu.ui_state = .Idle
		} else if get_input(.CANCEL) {
			battle_menu.ui_state = .Skills
		} else if m := get_menu_input(); m.x != 0 || m.y != 0 {
			battle_menu.ui_data.targets = target_update(
				m.x,
				m.y,
				battle_menu.ui_data.targets,
				skills[battle_menu.ui_data.skill].targeting,
			)
		}

	case .Inventory:
		if get_input(.ENTER) {
			if consumable, ok := items[inventory_order[battle_menu.ui_data.inv_sel.row_idx]].data.(Consumable); ok {
				battle_menu.ui_data.skill = consumable
				battle_menu.ui_state = .Item_Target
				battle_menu.ui_data.targets = default_target_selection(skills[consumable].targeting)
			}
		} else if get_input(.CANCEL) {
			battle_menu.ui_state = .Top
		} else if dy, ok := get_y_input().?; ok {
			battle_menu.ui_data.inv_sel = shift_windowed_selection(
				dy,
				battle_menu.ui_data.inv_sel,
				BATTLE_MENU_INVENTORY_ROWS,
				len(inventory_order),
			)
			battle_menu_set_stale(.Inventory)
		}

	case .Item_Target:
		if get_input(.ENTER) {
			queue_battle_skill(battle_menu.ui_data.c_idx, battle_menu.ui_data.targets, skills[battle_menu.ui_data.skill])
			battle_menu.ui_state = .Idle
		} else if get_input(.CANCEL) {
			battle_menu.ui_state = .Inventory
		} else if m := get_menu_input(); m.x != 0 || m.y != 0 {
			battle_menu.ui_data.targets = target_update(
				m.x,
				m.y,
				battle_menu.ui_data.targets,
				skills[battle_menu.ui_data.skill].targeting,
			)
		}
	}
	battle_update_icons()
}

battle_update_icons :: proc() {
	animation_update(&world_menu_icon, rl.GetFrameTime())
}

// /////// //
// HELPERS //
// /////// //

change_ally_selection :: proc(t, d: int) -> int {
	target := t + d
	if target < 0 {target = len(battle.allies) - 1}
	if target >= len(battle.allies) {target = 0}
	return target
}

change_baddy_selection :: proc(t, d: int) -> int {
	initial_target := t
	target := t + d
	for {
		if target < 0 {target = len(battle.baddies) - 1}
		if target >= len(battle.baddies) {target = 0}
		if target == initial_target {break}
		if battle.combatants[battle.baddies[target]].enabled {break}
		target += d
	}
	return target
	// targeting_ease = 0
}

select_first_baddy :: proc() -> int {
	return change_baddy_selection(MAX_ENCOUNTER_SIZE, 1)
}

target_update :: proc(dx, dy: int, ts: Target_Selection, tt: Target_Type) -> Target_Selection {
	switch ts in ts {
	case Target_One_Baddy:
		if dy != 0 {
			return Target_One_Baddy{change_baddy_selection(ts.i, dy)}
		} else if dx < 0 && tt != .One_Opponent && tt != .One_Combatant {
			return Target_All_Baddies{ts.i}
		} else if dx > 0 && tt == .One_Combatant {
			return Target_One_Ally{}
		}
	case Target_All_Baddies:
		if dx > 0 && tt != .All_Opponents {
			return Target_One_Baddy{ts.prev}
		}
	case Target_One_Ally:
		if dy != 0 {
			return Target_One_Ally{change_ally_selection(ts.i, dy)}
		} else if dx > 0 && tt != .One_Ally && tt != .One_Combatant {
			return Target_All_Allies{ts.i}
		} else if dx < 0 && tt == .One_Combatant {
			return Target_One_Baddy{}
		}
	case Target_All_Allies:
		if dx < 0 && tt != .All_Allies {
			return Target_One_Ally{ts.prev}
		}
	case Target_All_Combatants:
	// do nothing
	}
	return ts
}

default_target_selection :: proc(tt: Target_Type) -> Target_Selection {
	ts: Target_Selection
	switch tt {
	case .One_Opponent:
		ts = Target_One_Baddy{}
	case .Some_Opponents:
		ts = Target_One_Baddy{}
	case .All_Opponents:
		ts = Target_All_Baddies{}
	case .One_Combatant:
		ts = Target_One_Baddy{}
	case .One_Ally:
		ts = Target_One_Ally{}
	case .Some_Allies:
		ts = Target_One_Ally{}
	case .All_Allies:
		ts = Target_All_Allies{}
	case .All_Combatants:
		ts = Target_All_Combatants{}
	}
	return ts
}

// pc_turn :: proc(actor: int) {
// 	// if battle.pc_ui_state == nil {
// 	// 	battle.pc_ui_state = Action_Selection_State{}
// 	// 	return
// 	// }
// 	if get_input(.UP) {
// 		battle_change_selection(0, -1)
// 	} else if get_input(.DOWN) {
// 		battle_change_selection(0, 1)
// 	} else if get_input(.LEFT) {
// 		battle_change_selection(-1, 0)
// 	} else if get_input(.RIGHT) {
// 		battle_change_selection(1, 0)
// 	} else if get_input(.ENTER) {
// 		switch state in battle.pc_ui_state {
// 		case Action_Selection_State:
// 			switch state.s {
// 			case ATTACK:
// 				// skill_proc = attack
// 				skill = skills[Skill_Name.Slash]
// 				// todo: check weapon target type
// 				battle.pc_ui_state = Target_Selection_State {
// 					ts = Select_One_Baddy{select_first_baddy()},
// 					tt = .One_Opponent,
// 				}
// 			case SKILL:
// 				battle.pc_ui_state = Skill_Selection_State{}
// 				set_battle_skills(battle.combatants[actor])
// 			case ITEM:
// 				battle.pc_ui_state = Item_Selection_State{}
// 			}
// 		case Skill_Selection_State:
// 			skill = skills[battle.menu_skills[state.s]]
// 			battle.pc_ui_state = Target_Selection_State {
// 				ts = default_target_selection(skill.targeting),
// 				tt = skill.targeting,
// 			}
// 		case Item_Selection_State:
// 			if consumable, ok := items[state.s].data.(Consumable); ok {
// 				skill = skills[consumable]
// 				battle.pc_ui_state = Target_Selection_State {
// 					ts = default_target_selection(skill.targeting),
// 					tt = skill.targeting,
// 				}
// 			}
// 		case Target_Selection_State:
// 			queue_battle_skill(actor, state.ts, skill)
// 			battle.pc_ui_state = nil
// 			battle.pc_ready = nil
// 		}
// 	} else if get_input(.CANCEL) {
// 		switch state in battle.pc_ui_state {
// 		case Action_Selection_State:
// 		// do nothing
// 		case Skill_Selection_State:
// 			battle.pc_ui_state = Action_Selection_State{SKILL}
// 		case Item_Selection_State:
// 			battle.pc_ui_state = Action_Selection_State{ITEM}
// 		case Target_Selection_State:
// 			battle.pc_ui_state = Action_Selection_State{ATTACK} //fixme
// 		}
// 	} // else if get_input(.E) {
// 	// 	battle.pc_ui_state = PC_UI_State{}
// 	// 	battle.pc_ready = get_next_ready_pc()
// 	// }
// }
