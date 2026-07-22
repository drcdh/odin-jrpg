package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

World_Menu_UI_Data :: struct {
	top:       int,
	party_idx: int,
	slot_idx:  int,
	equip_sel: Selection,
	skill_sel: Selection,
	inv_sel:   Selection,
}

World_Menu_UI_State :: enum {
	Inactive,
	Top,
	Party,
	Character,
	Equipment,
	Skills,
	Skill_Target,
	Inventory,
	Item_Target,
	System,
}

World_Menu_Pane :: enum {
	Top,
	Party,
	Character,
	Equipment,
	Skills,
	Inventory,
	Targeting,
	System,
}

WORLD_MENU_NUM_TEXTURES :: len(World_Menu_Pane)

World_Menu :: struct {
	stale:        [WORLD_MENU_NUM_TEXTURES]bool,
	textures:     [WORLD_MENU_NUM_TEXTURES]rl.RenderTexture,
	ui_data:      World_Menu_UI_Data,
	ui_state:     World_Menu_UI_State,
	text_effects: [dynamic]Process_Text_Effect,
}

WORLD_MENU_PANE_ORIGINS := [WORLD_MENU_NUM_TEXTURES]Tile_Coord {
	{0, 0},
	{0, 2},
	{1, 1},
	{10, 2},
	{1, 1},
	{1, 1},
	{8, 5},
	{1, 1},
}

WORLD_MENU_PANE_DIM := [WORLD_MENU_NUM_TEXTURES]Tile_Coord {
	{VIEW_TILES_W, 2},
	{VIEW_TILES_W, VIEW_TILES_H - 2},
	{VIEW_TILES_W - 2, VIEW_TILES_H - 2},
	{6, 10},
	{VIEW_TILES_W - 2, VIEW_TILES_H - 2},
	{VIEW_TILES_W - 2, WORLD_MENU_INVENTORY_ROWS + 3},
	{7, 6},
	{VIEW_TILES_W - 2, VIEW_TILES_H - 2},
}

WORLD_MENU_INVENTORY_ROWS :: 10

world_menu_icon: Animation

world_menu: World_Menu

world_menu_load :: proc() {
	world_menu_icon = animation_create(.Select_Icon_Small)
	for pane in World_Menu_Pane {
		dim := WORLD_MENU_PANE_DIM[pane]
		world_menu.textures[pane] = rl.LoadRenderTexture(i32(dim.x) * i32(tile_size), i32(dim.y) * i32(tile_size))
	}
}

world_menu_unload :: proc() {
	for t in world_menu.textures {
		rl.UnloadRenderTexture(t)
	}
}

world_menu_enter :: proc() {
	world_menu.ui_data = World_Menu_UI_Data{}
	world_menu.ui_state = .Top

	for pane in World_Menu_Pane {
		world_menu_redraw_pane(pane)
	}
}

world_menu_exit :: proc() {
	world_menu.ui_state = .Inactive
}

world_menu_active :: proc() -> bool {
	return world_menu.ui_state != .Inactive
}

world_menu_set_stale :: proc(pane: World_Menu_Pane) {
	world_menu.stale[pane] = true
}

world_menu_draw :: proc() {
	for &stale, i in world_menu.stale {
		if stale {
			world_menu_redraw_pane(World_Menu_Pane(i))
			stale = false
		}
	}
	switch world_menu.ui_state {
	case .Inactive:
	case .Top:
		world_menu_draw_panes(.Top, .Party)
	case .Party:
		world_menu_draw_panes(.Top, .Party)
	case .Character:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.Character)
	case .Equipment:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.Character, .Equipment)
	case .Skills:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.Skills)
	case .Skill_Target:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.Skills, .Targeting)
	case .Inventory:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.Inventory)
	case .Item_Target:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.Inventory, .Targeting)
	case .System:
		world_menu_draw_panes(.Top, .Party, tint = rl.GRAY)
		world_menu_draw_panes(.System)
	}
	world_menu_draw_icons()
	world_menu_draw_text_effects()
}

world_menu_draw_icons :: proc() {
	switch world_menu.ui_state {
	case .Inactive:
	case .Top:
		draw_animation(world_menu_icon, tile_to_pixel(.5 + 3.5 * f32(world_menu.ui_data.top), .75))
	case .Party:
		p := world_menu.ui_data.party_idx
		draw_animation(
			world_menu_icon,
			tile_to_pixel(WORLD_MENU_PANE_ORIGINS[World_Menu_Pane.Party]) +
			tile_to_pixel(.5 + f32(5 * (p % 3)), 1 + 5 * int(p / 3)),
		)
	case .Character:
		s := world_menu.ui_data.slot_idx
		draw_animation(
			world_menu_icon,
			tile_to_pixel(WORLD_MENU_PANE_ORIGINS[World_Menu_Pane.Character]) + tile_to_pixel(.5, 2 + NUM_STATS + s),
		)
	case .Equipment:
		r := selection_row(world_menu.ui_data.equip_sel)
		draw_animation(
			world_menu_icon,
			tile_to_pixel(WORLD_MENU_PANE_ORIGINS[World_Menu_Pane.Equipment]) + tile_to_pixel(.5, 1 + r),
		)
	case .Skills:
	// r := selection_row(world_menu.ui_data.skill_sel)
	// draw_animation(world_menu_icon, tile_to_pixel(1, 1 + r))
	case .Skill_Target:
	case .Inventory:
		r := selection_row(world_menu.ui_data.inv_sel)
		draw_animation(
			world_menu_icon,
			tile_to_pixel(WORLD_MENU_PANE_ORIGINS[World_Menu_Pane.Inventory]) + tile_to_pixel(.5, 1 + r),
		)
	case .Item_Target:
		p := world_menu.ui_data.party_idx
		row := f32(p / 3)
		draw_animation(
			world_menu_icon,
			tile_to_pixel(WORLD_MENU_PANE_ORIGINS[World_Menu_Pane.Targeting]) +
			tile_to_pixel(.5 + 2 * (f32(p) - 3 * row), 1 + 2.5 * row),
			rl.WHITE,
		)
	case .System:
	}
}

world_menu_redraw_top_pane :: proc() {
	draw_text(1, .75, strings.clone_to_cstring("Info   Skills Items  System", allocator = context.temp_allocator))
}

world_menu_redraw_party_pane :: proc() {
	for p in 0 ..< party_size() {
		if pc_idx, ok := get_party_member(p).?; ok {
			world_menu_draw_party_member(pc_idx, {1, 1} + {p % 3, int(p / 3)} * {5, 5})
		}
	}
}

world_menu_redraw_character_pane :: proc() {
	if pc_idx, ok := get_party_member(world_menu.ui_data.party_idx).?; ok {
		pc := get_pc(pc_idx)
		draw_text(1, 1, fmt.ctprintf("%-12s %s", pc.name, fmt.ctprintf("L% 2d", pc.level)))
		#partial switch world_menu.ui_state {
		case .Character:
			for s in Stat {
				draw_text(1, 2 + f32(s), strings.clone_to_cstring(stat_string(pc^, s), context.temp_allocator))
			}
		case .Equipment:
			item_name := equippables_order[selection_row(world_menu.ui_data.equip_sel)]
			slot_idx := world_menu.ui_data.slot_idx
			changing_stats := equipped_stats(pc.leveled_stats, changed_equipment(pc.equipment, item_name, slot_idx))
			for s in Stat {
				tint := change_tint(get_stat(pc^, s), get_stat(changing_stats, s))
				draw_text(
					1,
					2 + f32(s),
					strings.clone_to_cstring(stat_string(changing_stats, s), context.temp_allocator),
					tint,
				)
			}
			fmt.printfln("trying on %s\n%#v", item_name, changing_stats)
		}
		for s in Equipment_Slot {
			draw_text(
				1,
				2 + NUM_STATS + f32(s),
				strings.clone_to_cstring(equipment_string(pc.equipment, s), context.temp_allocator),
			)
		}
		draw_text(1, 2 + NUM_STATS, get_status_cstring(pc^))
	}
}

world_menu_redraw_equipment_pane :: proc() {
	origin_idx := world_menu.ui_data.equip_sel.origin_idx
	for r in 0 ..< 8 {
		if r >= len(equippables_order) {break}
		item_name := equippables_order[r + origin_idx]
		if item_name == .None {
			draw_text(1, 1 + f32(r), "remove", rl.WHITE)
		} else {
			tint := rl.WHITE if fits_in_slot(item_name, Equipment_Slot(world_menu.ui_data.slot_idx)) else rl.GRAY
			draw_text(1, 1 + f32(r), fmt.ctprint(items[item_name].name), tint)
		}
	}
}

world_menu_redraw_skills_pane :: proc() {
	row := 0
	if pc_idx, ok := get_party_member(world_menu.ui_data.party_idx).?; ok {
		pc := get_pc(pc_idx)
		for k in Skill_Name {
			if skill_in_set(k, pc.skills) {
				draw_text(
					1,
					1 + f32(row),
					fmt.ctprintf("%-12s % 3.0f", skills[k].name, 100 * f16(pc.skills.charges[k]) / CHARGE_MAX),
				)
				// draw_text(1, 1 + f32(row), fmt.ctprint(skills[k].name))
				row += 1
			}
		}
	}
}

world_menu_redraw_inventory_pane :: proc() {
	origin_idx := world_menu.ui_data.inv_sel.origin_idx
	for r in 0 ..< WORLD_MENU_INVENTORY_ROWS {
		if r >= len(inventory_order) {break}
		draw_text(1, 1 + f32(r), fmt.ctprint(items[inventory_order[r + origin_idx]].name))
		draw_text_rjust(13, 1 + f32(r), fmt.ctprint(game_data.inventory[inventory_order[r + origin_idx]]))
	}

	draw_text_rjust(13, WORLD_MENU_INVENTORY_ROWS + 1.5, fmt.ctprintf("$ %d", game_data.money))
}

world_menu_redraw_targeting_pane :: proc() {
	row: f32 = 0
	for i in 0 ..< party_size() {
		if i == 3 {
			row += 1
		}
		if pc_idx, ok := get_party_member(i).?; ok {
			draw_texture(pc_idle_texture[pc_idx], tile_to_pixel(1 + 2 * (f32(i) - 3 * row), 1 + 2.5 * row))
		}
	}
}

world_menu_redraw_system_pane :: proc() {}

world_menu_redraw_pane :: proc(pane: World_Menu_Pane) {
	rl.BeginTextureMode(world_menu.textures[pane])
	draw_pane(WORLD_MENU_PANE_DIM[pane])
	switch pane {
	case .Top:
		world_menu_redraw_top_pane()
	case .Party:
		world_menu_redraw_party_pane()
	case .Character:
		world_menu_redraw_character_pane()
	case .Equipment:
		world_menu_redraw_equipment_pane()
	case .Skills:
		world_menu_redraw_skills_pane()
	case .Inventory:
		world_menu_redraw_inventory_pane()
	case .Targeting:
		world_menu_redraw_targeting_pane()
	case .System:
		world_menu_redraw_system_pane()
	}
	rl.EndTextureMode()
}

world_menu_draw_pane :: proc(pane: World_Menu_Pane, tint := rl.WHITE) {
	origin_tile := WORLD_MENU_PANE_ORIGINS[pane]
	origin := tile_to_pixel(origin_tile)
	texture := world_menu.textures[pane].texture
	w := f32(texture.width)
	h := f32(texture.height)
	dest := rl.Rectangle{origin.x, origin.y, w, -h}
	rl.DrawTexturePro(texture, {0, 0, w, -h}, dest, {}, 0, tint)
}

world_menu_draw_panes :: proc(panes: ..World_Menu_Pane, tint := rl.WHITE) {
	for pane in panes {
		world_menu_draw_pane(pane, tint)
	}
}

world_menu_draw_party_member :: proc(pc_idx: PC, origin: Tile_Coord) {
	pc := get_pc(pc_idx)
	draw_text(f32(origin.x), f32(origin.y), pc.name)
	hp_tint := rl.WHITE
	hp := pc.hitpoints
	max_hp := pc.max_hitpoints
	if hp <= 0 {
		hp_tint = rl.RED
	} else if hp <= max_hp / 4 {
		hp_tint = rl.ORANGE
	}
	origin := origin
	origin.y += 1
	draw_text(f32(origin.x), f32(origin.y), fmt.ctprintf("%d/%d", hp, max_hp), hp_tint)
	draw_texture(pc_idle_texture[pc_idx], tile_to_pixel(origin.x + 3, f32(origin.y) + .5))
}

world_menu_draw_text_effects :: proc() {
	for te in world_menu.text_effects {
		pos := Pixel_Coord{te.coord.x - 32, te.coord.y - 32 * te.t}
		rl.DrawTextEx(font, te.text, pos, 32, 0, rl.Color{te.color.x, te.color.y, te.color.z, u8(255 * (1 - te.t))})
	}
}

world_menu_update :: proc() {
	switch world_menu.ui_state {
	case .Inactive:
	case .Top:
		if get_input(.CANCEL) {
			world_menu_exit()
		} else if get_input(.ENTER) {
			switch world_menu.ui_data.top {
			case 0:
				world_menu.ui_state = .Party
			case 1:
				world_menu.ui_state = .Party
			case 2:
				world_menu.ui_state = .Inventory
			case 3:
				world_menu.ui_state = .System
			}
		} else if dx, ok := get_x_input().?; ok {
			world_menu.ui_data.top = grid_change(world_menu.ui_data.top, dx, 0, 4, 1)
		}
	case .Party:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Top
		} else if get_input(.ENTER) {
			switch world_menu.ui_data.top {
			case 0:
				world_menu.ui_state = .Character
				world_menu_set_stale(.Character)
			case 1:
				world_menu.ui_state = .Skills
				world_menu_set_stale(.Skills)
			}
		} else {
			world_menu.ui_data.party_idx = change_world_menu_party_idx_from_input(world_menu.ui_data.party_idx)
		}
	case .Character:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Party
		} else if get_input(.ENTER) {
			world_menu.ui_state = .Equipment
			world_menu_set_stale(.Character)
			world_menu_set_stale(.Equipment)
		} else {
			m := get_menu_input()
			if m.x != 0 {
				world_menu.ui_data.party_idx += m.x
				world_menu.ui_data.party_idx %%= party_size()
				world_menu_set_stale(.Character)
			} else if m.y != 0 {
				world_menu.ui_data.slot_idx += m.y
				world_menu.ui_data.slot_idx %%= NUM_EQUIPMENT_SLOTS
			}
		}
	case .Equipment:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Character
			world_menu_set_stale(.Character)
		} else if get_input(.ENTER) {
			equipment_slot := Equipment_Slot(world_menu.ui_data.slot_idx)
			item_name := equippables_order[world_menu.ui_data.equip_sel.row_idx]
			if fits_in_slot(item_name, equipment_slot) {
				pc_idx := get_party_member(world_menu.ui_data.party_idx).?
				pc := get_pc(pc_idx)
				character_set_equipped_item(pc, equipment_slot, item_name)
				world_menu.ui_state = .Character
				world_menu_set_stale(.Character)
				world_menu_set_stale(.Inventory)
			} else {
				fmt.println(item_name, " does not fit in ", equipment_slot)
			}
		} else {
			if dy, ok := get_y_input().?; ok {
				world_menu.ui_data.equip_sel = shift_windowed_selection(
					dy,
					world_menu.ui_data.equip_sel,
					8,
					len(equippables_order),
				)
				world_menu_set_stale(.Character)
				world_menu_set_stale(.Equipment)
			}
		}
	case .Skills:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Party
		} else if get_input(.ENTER) {
			// TODO
		} else if dx, ok := get_x_input().?; ok {
			world_menu.ui_data.party_idx += dx
			world_menu.ui_data.party_idx %%= party_size()
			world_menu_set_stale(.Skills)
		} // TODO: get_y_input
	case .Skill_Target:
	// TODO
	case .Inventory:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Top
		} else if get_input(.ENTER) {
			item_name := inventory_order[world_menu.ui_data.inv_sel.row_idx]
			if _, consumable := items[item_name].data.(Consumable); consumable {
				world_menu.ui_state = .Item_Target
			} else {
				fmt.printfln("Item %s isn't a Consumable", items[item_name])
				play_sound(.Blerp)
			}
		} else if dy, ok := get_y_input().?; ok {
			world_menu.ui_data.inv_sel = shift_windowed_selection(
				dy,
				world_menu.ui_data.inv_sel,
				WORLD_MENU_INVENTORY_ROWS,
				len(inventory_order),
			)
			world_menu_set_stale(.Inventory)
		}
	case .Item_Target:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Inventory
		} else if get_input(.ENTER) {
			item_name := inventory_order[world_menu.ui_data.inv_sel.row_idx]
			party_idx := world_menu.ui_data.party_idx
			if consumable, ok := items[item_name].data.(Consumable); ok {
				skill = skills[consumable]
				play_sound(skill.sound) // todo
				pc_idx := get_party_member(party_idx).?
				do_effect(nil, get_pc(pc_idx), skill.effect)
				remove_item(item_name)
				if game_data.inventory[item_name] == 0 {
					world_menu.ui_state = .Inventory
				}
				world_menu_set_stale(.Party)
				world_menu_set_stale(.Inventory)
				world_menu_set_stale(.Targeting)
				fmt.printfln("Used item %s on %s", item_name, pc_idx)
			} else {
				fmt.println("Uh oh! Tried to use non-consumable %s", item_name)
			}
		} else {
			world_menu.ui_data.party_idx = change_world_menu_party_idx_from_input(world_menu.ui_data.party_idx)
		}
	case .System:
		if get_input(.CANCEL) {
			world_menu.ui_state = .Top
		}
	}
	animation_update(&world_menu_icon, rl.GetFrameTime())
	for text_idx := 0; text_idx < len(world_menu.text_effects); {
		world_menu.text_effects[text_idx].t += rl.GetFrameTime()
		if world_menu.text_effects[text_idx].t >= 1 {
			delete(world_menu.text_effects[text_idx].text)
			unordered_remove(&world_menu.text_effects, text_idx)
		} else {
			text_idx += 1
		}
	}
}
