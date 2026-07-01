package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

World_Menu_State_Top :: struct {
	i:         int,
	next:      bool,
	party_idx: int,
}
World_Menu_State_Character :: struct {
	party_idx:  int,
	slot_idx:   int,
	changing:   bool,
	item_idx:   int,
	origin_idx: int,
}
World_Menu_State_Skills :: struct {
	party_idx:  int,
	skill_idx:  int,
	origin_idx: int,
}
World_Menu_State_Items :: struct {
	item_idx:   int,
	origin_idx: int,
	targeting:  bool,
	party_idx:  int,
}
World_Menu_State_System :: struct {
	i: int,
}

World_Menu_State :: union {
	World_Menu_State_Top,
	World_Menu_State_Character,
	World_Menu_State_Skills,
	World_Menu_State_Items,
	World_Menu_State_System,
}

WORLD_MENU_ITEMS_ROWS :: 10

world_menu_active: bool
world_menu_state: World_Menu_State

world_menu_icon: Animation

changing_stats: Stats

init_world_menu :: proc() {
	world_menu_icon = animation_create(.Select_Icon_Small)
	world_menu_state = World_Menu_State_Top{}
}

draw_world_menu :: proc() {
	switch state in world_menu_state {
	case World_Menu_State_Top:
		draw_world_menu_top(state.i, state.next, state.party_idx)
	case World_Menu_State_Character:
		draw_world_menu_top(0, true, state.party_idx, rl.GRAY)
		draw_world_menu_character(state.party_idx, state.slot_idx, state.changing, state.item_idx, state.origin_idx)
	case World_Menu_State_Skills:
		draw_world_menu_top(1, true, state.party_idx, rl.GRAY)
		draw_world_menu_skills(state.party_idx, state.skill_idx, state.origin_idx)
	case World_Menu_State_Items:
		draw_world_menu_top(2, true, 0, rl.GRAY)
		draw_world_menu_items(state.item_idx, state.origin_idx, state.targeting, state.party_idx)
	case World_Menu_State_System:
		draw_world_menu_top(3, true, 0, rl.GRAY)
		draw_world_menu_system(state.i)
	}
	rl.DrawText(
		fmt.caprint(world_menu_state, allocator = context.temp_allocator),
		i32(tile_size),
		i32(view_dim.y - tile_size),
		20,
		rl.PURPLE,
	)
}

draw_world_menu_top :: proc(i: int, next: bool, party_idx: int, tint := rl.WHITE) {
	draw_menu(0, 0, VIEW_TILES_W, 2, tint)
	draw_text(1, .75, strings.clone_to_cstring("Info   Skills  Items  System", allocator = context.temp_allocator), tint)

	if !next {
		x_icon: f32
		switch i {
		case 0:
			x_icon = .5 * tile_size
		case 1:
			x_icon = 4 * tile_size
		case 2:
			x_icon = 8 * tile_size
		case 3:
			x_icon = 11.5 * tile_size
		}
		draw_animation(world_menu_icon, {x_icon, .75 * tile_size}, tint)
	}

	draw_menu(0, 2, VIEW_TILES_W, VIEW_TILES_H - 2, tint)
	card := 0
	row: f32 = 0
	for p in 0 ..< party_size() {
		if pc, ok := get_party_member(p).?; ok {
			card_origin :=
				Pixel_Coord{tile_size, 3 * tile_size} + {f32(card % 3), row} * Pixel_Coord{5 * tile_size, 5 * tile_size}
			draw_character_card(pc, card_origin)
			card += 1
			if p == 2 {
				card = 0
				row += 1
			}
			if next && p == party_idx {
				card_origin.x -= .5 * tile_size
				draw_animation(world_menu_icon, card_origin, tint)
			}
		}
	}
}

draw_character_card :: proc(pc_idx: PC, origin: Pixel_Coord, tint := rl.WHITE) {
	// rl.DrawRectangleLinesEx({origin.x, origin.y, 5 * tile_size, 6 * tile_size}, 2, tint)
	pc := get_pc(pc_idx)
	rl.DrawTextEx(font, pc.name, origin, 32, 0, tint)
	hp_tint := rl.WHITE
	hp := pc.hitpoints
	max_hp := pc.max_hitpoints
	if hp <= 0 {
		hp_tint = rl.RED
	} else if hp <= max_hp / 4 {
		hp_tint = rl.ORANGE
	}
	origin := origin
	origin.y += tile_size
	rl.DrawTextEx(font, fmt.caprintf("%d/%d", hp, max_hp, allocator = context.temp_allocator), origin, 32, 0, hp_tint)

	draw_texture(pc_idle_texture[pc_idx], {origin.x + 3 * tile_size, origin.y + .5 * tile_size}, tint)
}

draw_world_menu_character :: proc(party_idx, slot_idx: int, changing: bool, item_idx, origin_idx: int) {
	draw_menu(1, 1, VIEW_TILES_W - 2, VIEW_TILES_H - 2)
	if pc_idx, ok := get_party_member(party_idx).?; ok {
		pc := get_pc(pc_idx)
		draw_text(
			2,
			2,
			fmt.caprintf(
				"%-12s %s",
				pc.name,
				fmt.caprintf("L% 2d", pc.level, allocator = context.temp_allocator),
				allocator = context.temp_allocator,
			),
		)
		for i in 0 ..< NUM_STATS {
			s := Stat(i)
			if !changing {
				draw_text(2, 3 + f32(i), strings.clone_to_cstring(stat_string(pc^, s), context.temp_allocator))
			} else {
				tint := change_tint(get_stat(pc^, s), get_stat(changing_stats, s))
				draw_text(
					2,
					3 + f32(i),
					strings.clone_to_cstring(stat_string(changing_stats, s), context.temp_allocator),
					tint,
				)
			}
		}
		for i in 0 ..< NUM_EQUIPMENT_SLOTS {
			if i == slot_idx {
				draw_animation(world_menu_icon, tile_to_pixel(1.5, 3 + NUM_STATS + i), rl.GRAY if changing else rl.WHITE)
			}
			draw_text(
				2,
				3 + NUM_STATS + f32(i),
				strings.clone_to_cstring(equipment_string(pc^, Equipment_Slot(i)), context.temp_allocator),
			)
		}
		draw_text(2, 3 + NUM_STATS, get_status_cstring(pc^))

		if changing {
			draw_menu(10, 2, 6, 10)
			for r in 0 ..< 8 {
				if r >= len(equippables_order) {break}
				if r + origin_idx == item_idx {
					draw_animation(world_menu_icon, tile_to_pixel(10.5, 3 + r))
				}
				item_name := equippables_order[r + origin_idx]
				if item_name == .None {
					draw_text(11, 3 + f32(r), "remove", rl.WHITE)
				} else {
					tint := rl.WHITE if fits_in_slot(item_name, Equipment_Slot(slot_idx)) else rl.GRAY
					draw_text(11, 3 + f32(r), fmt.caprint(items[item_name].name, allocator = context.temp_allocator), tint)
					// draw_text(
					// 	VIEW_TILES_W - 3,
					// 	4 + f32(r),
					// 	fmt.caprintf("% 2d", game_data.inventory[r + origin_idx], allocator = context.temp_allocator),
					// 	tint,
					// )
				}
			}
		}
	}
}

draw_world_menu_skills :: proc(party_idx, skill_idx, origin_idx: int) {
	draw_menu(1, 1, VIEW_TILES_W - 2, VIEW_TILES_H - 2)
	pc_idx, ok := get_party_member(party_idx).?
	if !ok {return}
	pc := get_pc(pc_idx)
	r := 0
	for k in 0 ..< len(Skill_Name) {
		if Skill_Name(k) in pc.skills {
			draw_text(2, 2 + f32(r), fmt.caprint(skills[k].name, allocator = context.temp_allocator))
			r += 1
		}
	}
}

draw_world_menu_items :: proc(item_idx, origin_idx: int, targeting: bool, party_idx: int) {
	tint := rl.WHITE
	if targeting {tint = rl.GRAY}
	draw_menu(1, 1, VIEW_TILES_W - 2, WORLD_MENU_ITEMS_ROWS + 3, tint)
	draw_text(
		2,
		WORLD_MENU_ITEMS_ROWS + 3,
		fmt.caprintf(
			"% 24s",
			fmt.caprintf("$ %d", game_data.money, allocator = context.temp_allocator),
			allocator = context.temp_allocator,
		),
		tint = tint,
	)
	for r in 0 ..< WORLD_MENU_ITEMS_ROWS {
		if r >= len(inventory_order) {break}
		if r + origin_idx == item_idx {
			draw_animation(world_menu_icon, tile_to_pixel(1.5, 2 + r), tint)
		}
		draw_text(
			2,
			2 + f32(r),
			fmt.caprint(items[inventory_order[r + origin_idx]].name, allocator = context.temp_allocator),
			tint = tint,
		)
		draw_text(
			VIEW_TILES_W - 3,
			2 + f32(r),
			fmt.caprintf("% 2d", game_data.inventory[inventory_order[r + origin_idx]], allocator = context.temp_allocator),
			tint = tint,
		)
	}
	if targeting {
		draw_menu(8, 5, 7, 6)
		row := f32(0)
		for i in 0 ..< party_size() {
			if i == 3 {
				row += 1
			}
			if pc_idx, ok := get_party_member(i).?; ok {
				draw_texture(pc_idle_texture[pc_idx], tile_to_pixel(9 + 2 * (f32(i) - 3 * row), 6 + 2.5 * row), rl.WHITE)
				if i == party_idx {
					draw_animation(world_menu_icon, tile_to_pixel(8.5 + 2 * (f32(i) - 3 * row), 6 + 2.5 * row), rl.WHITE)
				}
			}
		}
	}
}

draw_world_menu_system :: proc(i: int) {
	draw_menu(1, 1, VIEW_TILES_W - 2, VIEW_TILES_H - 2)
}

update_world_menu :: proc() {
	if get_input(.MENU) {
		world_menu_active = false
	}
	switch state in world_menu_state {
	case World_Menu_State_Top:
		update_world_menu_top(state.i, state.next, state.party_idx)
	case World_Menu_State_Character:
		update_world_menu_character(state.party_idx, state.slot_idx, state.changing, state.item_idx, state.origin_idx)
	case World_Menu_State_Skills:
		update_world_menu_skills(state.party_idx)
	case World_Menu_State_Items:
		update_world_menu_items(state.item_idx, state.origin_idx, state.targeting, state.party_idx)
	case World_Menu_State_System:
		update_world_menu_system(state.i)
	}
	animation_update(&world_menu_icon, rl.GetFrameTime())
}

update_world_menu_top :: proc(i: int, next: bool, party_idx: int) {
	if next {
		if get_input(.CANCEL) {
			world_menu_state = World_Menu_State_Top{i, false, party_idx}
		} else if get_input(.ENTER) {
			switch i {
			case 0:
				world_menu_state = World_Menu_State_Character{party_idx, 0, false, 0, 0}
			case 1:
				world_menu_state = World_Menu_State_Skills{party_idx, 0, 0}
			}
		} else {
			world_menu_state = World_Menu_State_Top{i, true, change_world_menu_party_idx_from_input(party_idx)}
		}
	} else {
		if get_input(.CANCEL) {
			world_menu_active = false
		} else if get_input(.ENTER) {
			switch i {
			case 0 ..= 1:
				world_menu_state = World_Menu_State_Top{i, true, party_idx}
			case 2:
				world_menu_state = World_Menu_State_Items{}
			case 3:
				world_menu_state = World_Menu_State_System{}
			}
		} else {
			i := i
			m := get_menu_input()
			if m.x != 0 {
				i += m.x
				if i < 0 {i = 3}
				if i >= 4 {i = 0}
				world_menu_state = World_Menu_State_Top{i, next, party_idx}
			} else if m.y > 0 {
				world_menu_state = World_Menu_State_Top{i, true, party_idx}
			}
		}
	}
}

update_world_menu_character :: proc(party_idx, slot_idx: int, changing: bool, item_idx, origin_idx: int) {
	if changing {
		if get_input(.CANCEL) {
			world_menu_state = World_Menu_State_Character{party_idx, slot_idx, false, item_idx, origin_idx}
		} else if get_input(.ENTER) {
			equipment_slot := Equipment_Slot(slot_idx)
			item_name := equippables_order[item_idx]
			if fits_in_slot(item_name, equipment_slot) {
				pc := get_pc(party_idx)
				set_equipped_item(pc, equipment_slot, item_name)
				pc.stats = equipped_stats(pc.leveled_stats, pc.equipment)
				pc.hitpoints = min(pc.hitpoints, pc.max_hitpoints)
				set_skills(party_idx) // is this correct when there are gaps in the party? e.g., members 1 and 3, not 2
				world_menu_state = World_Menu_State_Character{party_idx, slot_idx, false, 0, 0}
			} else {
				fmt.println(item_name, " does not fit in ", equipment_slot)
			}
		} else {
			m := get_menu_input()
			if m.y != 0 {
				pc := get_pc(party_idx)
				item_idx, origin_idx := item_idx, origin_idx
				item_idx, origin_idx = shift_windowed_selection(m.y, item_idx, origin_idx, 8, len(equippables_order))
				changing_stats = equipped_stats(
					pc.leveled_stats,
					changed_equipment(pc.equipment, equippables_order[item_idx], slot_idx),
				)
				world_menu_state = World_Menu_State_Character{party_idx, slot_idx, changing, item_idx, origin_idx}
			}
		}
	} else {
		if get_input(.CANCEL) {
			world_menu_state = World_Menu_State_Top{0, true, party_idx}
		} else if get_input(.ENTER) {
			pc := get_pc(party_idx)
			changing_stats = equipped_stats(
				pc.leveled_stats,
				changed_equipment(pc.equipment, equippables_order[item_idx], slot_idx),
			)
			world_menu_state = World_Menu_State_Character{party_idx, slot_idx, true, item_idx, origin_idx}
		} else {
			m := get_menu_input()
			if m.x != 0 {
				party_idx := party_idx
				party_idx += m.x
				if party_idx < 0 {party_idx = party_size() - 1}
				if party_idx >= party_size() {party_idx = 0}
				world_menu_state = World_Menu_State_Character {
					party_idx = party_idx,
					slot_idx  = slot_idx,
				}
			} else if m.y != 0 {
				slot_idx := slot_idx
				slot_idx, _ = shift_windowed_selection(m.y, slot_idx, 0, NUM_EQUIPMENT_SLOTS, NUM_EQUIPMENT_SLOTS)
				world_menu_state = World_Menu_State_Character{party_idx, slot_idx, changing, item_idx, origin_idx}
			}
		}
	}
}

update_world_menu_skills :: proc(party_idx: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top{1, true, party_idx}
	}
}

update_world_menu_items :: proc(item_idx, origin_idx: int, targeting: bool, party_idx: int) {
	if get_input(.CANCEL) {
		if targeting {
			world_menu_state = World_Menu_State_Items{item_idx, origin_idx, false, party_idx}
		} else {
			world_menu_state = World_Menu_State_Top {
				i = 2,
			}
		}
	} else if get_input(.ENTER) {
		item_name := inventory_order[item_idx]
		if targeting {
			if consumable, ok := items[item_name].data.(Consumable); ok {
				skill = skills[consumable]
				play_sound(skill.sound) // todo
				do_world_effect(nil, get_pc(party_idx), skill.effect)
				game_data.inventory[item_name] -= 1
				if game_data.inventory[item_name] == 0 {
					world_menu_state = World_Menu_State_Items{item_idx, origin_idx, false, party_idx}
				}
				fmt.printfln("Used item %s", item_name)
			} else {
				fmt.println("Uh oh! Tried to use non-consumable %s", item_name)
			}
		} else {
			if _, consumable := items[item_name].data.(Consumable); consumable {
				world_menu_state = World_Menu_State_Items{item_idx, origin_idx, true, 0}
			} else {
				fmt.printfln("Item %s isn't a Consumable", items[item_name])
				play_sound(.Blerp)
			}
		}
	} else {
		if targeting {
			world_menu_state = World_Menu_State_Items {
				item_idx,
				origin_idx,
				true,
				change_world_menu_party_idx_from_input(party_idx),
			}
		} else {
			m := get_menu_input()
			if m.y != 0 {
				s, w := shift_windowed_selection(m.y, item_idx, origin_idx, 10, len(inventory_order))
				world_menu_state = World_Menu_State_Items{s, w, targeting, party_idx}
			}
		}
	}
}

update_world_menu_system :: proc(i: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top {
			i = 3,
		}
	}
}
