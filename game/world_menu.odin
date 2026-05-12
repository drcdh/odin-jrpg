package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

World_Menu_State_Top :: struct {
	i:      int,
	next:   bool,
	pc_idx: int,
}
World_Menu_State_Character :: struct {
	pc_idx: int,
}
World_Menu_State_Skills :: struct {
	pc_idx: int,
}
World_Menu_State_Items :: struct {
	item_idx:  int,
	targeting: bool,
	pc_idx:    int,
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

world_menu_active: bool
world_menu_state: World_Menu_State

world_menu_icon: Animation

init_world_menu :: proc() {
	world_menu_icon = animation_create(.Select_Icon_Small)
	world_menu_state = World_Menu_State_Top{}
}

draw_world_menu :: proc() {
	switch state in world_menu_state {
	case World_Menu_State_Top:
		draw_world_menu_top(state.i, state.next, state.pc_idx)
	case World_Menu_State_Character:
		draw_world_menu_top(0, true, state.pc_idx, rl.GRAY)
		draw_world_menu_character(state.pc_idx)
	case World_Menu_State_Skills:
		draw_world_menu_top(1, true, state.pc_idx, rl.GRAY)
		draw_world_menu_skills(state.pc_idx)
	case World_Menu_State_Items:
		draw_world_menu_top(2, true, 0, rl.GRAY)
		draw_world_menu_items(state.item_idx, state.targeting, state.pc_idx)
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

draw_world_menu_top :: proc(i: int, next: bool, pc_idx: int, tint := rl.WHITE) {
	draw_menu(0, 0, VIEW_TILES_W, 2, tint)
	x: f32 = 1 * tile_size
	y: f32 = .75 * tile_size
	rl.DrawTextEx(
		font,
		strings.clone_to_cstring("Info   Skills  Items  System", allocator = context.temp_allocator),
		{x, y},
		tile_size / 2,
		0,
		tint,
	)

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
		draw_animation(world_menu_icon, {x_icon, y}, tint)
	}

	draw_menu(0, 2, VIEW_TILES_W, VIEW_TILES_H - 2, tint)
	card := 0
	row: f32 = 0
	for p in 0 ..< NUM_PC {
		{ 	//if character in party
			card_origin :=
				Pixel_Coord{tile_size, 3 * tile_size} + {f32(card % 3), row} * Pixel_Coord{5 * tile_size, 5 * tile_size}
			draw_character_card(PC(p), card_origin)
			card += 1
			if p == 2 {
				card = 0
				row += 1
			}
			if next && p == pc_idx {
				card_origin.x -= .5 * tile_size
				draw_animation(world_menu_icon, card_origin, tint)
			}
		}
	}
}

draw_character_card :: proc(pc: PC, origin: Pixel_Coord, tint := rl.WHITE) {
	// tint := pc_idle_anim_tint[pc]
	// rl.DrawRectangleLinesEx({origin.x, origin.y, 5 * tile_size, 6 * tile_size}, 2, tint)
	pc := get_pc(pc)
	rl.DrawTextEx(font, pc.name, origin, 32, 0, tint)

	draw_texture(.Protagonist_Battle0, {origin.x + 3 * tile_size, origin.y + .5 * tile_size}, tint)

	// stats_origin := Pixel_Coord{origin.x, origin.y + 2 * tile_size}
}

draw_world_menu_character :: proc(pc_idx: int) {
	draw_menu(1, 1, VIEW_TILES_W - 2, VIEW_TILES_H - 2)
	pc := get_pc(PC(pc_idx))
	rl.DrawTextEx(font, pc.name, {2 * tile_size, 2 * tile_size}, tile_size / 2, 0, rl.WHITE)
	for i in 0 ..< NUM_STATS {
		rl.DrawTextEx(
			font,
			strings.clone_to_cstring(stat_string(pc^, Stat(i)), context.temp_allocator),
			{2 * tile_size, 3 * tile_size + f32(i) * tile_size},
			tile_size / 2,
			0,
			rl.WHITE,
		)
	}
	rl.DrawTextEx(
		font,
		get_status_cstring(pc^),
		{2 * tile_size, 3 * tile_size + f32(NUM_STATS) * tile_size},
		tile_size / 2,
		0,
		rl.WHITE,
	)
}

draw_world_menu_skills :: proc(pc_idx: int) {
	draw_menu(1, 1, VIEW_TILES_W - 2, VIEW_TILES_H - 2)
}

draw_world_menu_items :: proc(item_idx: int, targeting: bool, pc_idx: int) {
	tint := rl.WHITE
	if targeting {tint = rl.GRAY}
	draw_menu(1, 1, VIEW_TILES_W - 2, VIEW_TILES_H - 2, tint)
	for i in 0 ..< len(Item) {
		if i == item_idx {
			draw_animation(world_menu_icon, tile_to_pixel(1.5, 2 + i), tint)
		}
		rl.DrawTextEx(
			font,
			fmt.caprint(item_data[i].name, allocator = context.temp_allocator),
			tile_to_pixel(2, 2 + i),
			tile_size / 2,
			0,
			tint,
		)
		rl.DrawTextEx(
			font,
			fmt.caprintf("% 2d", game_data.inventory[i], allocator = context.temp_allocator),
			tile_to_pixel(VIEW_TILES_W - 3, 2 + i),
			tile_size / 2,
			0,
			tint,
		)
	}
	if targeting {
		draw_menu(8, 5, 7, 6)
		row := f32(0)
		for i in 0 ..< NUM_PC {
			if i == 3 {
				row += 1
			}
			draw_texture(.Protagonist_Battle0, tile_to_pixel(9 + 2 * (f32(i) - 3 * row), 6 + 2.5 * row), rl.WHITE)
			if i == pc_idx {
				draw_animation(world_menu_icon, tile_to_pixel(8.5 + 2 * (f32(i) - 3 * row), 6 + 2.5 * row), rl.WHITE)
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
		update_world_menu_top(state.i, state.next, state.pc_idx)
	case World_Menu_State_Character:
		update_world_menu_character(state.pc_idx)
	case World_Menu_State_Skills:
		update_world_menu_skills(state.pc_idx)
	case World_Menu_State_Items:
		update_world_menu_items(state.item_idx, state.targeting, state.pc_idx)
	case World_Menu_State_System:
		update_world_menu_system(state.i)
	}
	animation_update(&world_menu_icon, rl.GetFrameTime())
}

update_world_menu_top :: proc(i: int, next: bool, pc_idx: int) {
	if next {
		if get_input(.CANCEL) {
			world_menu_state = World_Menu_State_Top{i, false, pc_idx}
		} else if get_input(.ENTER) {
			switch i {
			case 0:
				world_menu_state = World_Menu_State_Character{pc_idx}
			case 1:
				world_menu_state = World_Menu_State_Skills{pc_idx}
			}
		} else {
			world_menu_state = World_Menu_State_Top{i, true, change_world_menu_pc_dx_from_input(pc_idx)}
		}
	} else {
		if get_input(.CANCEL) {
			world_menu_active = false
		} else if get_input(.ENTER) {
			switch i {
			case 0 ..= 1:
				world_menu_state = World_Menu_State_Top{i, true, pc_idx}
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
				world_menu_state = World_Menu_State_Top{i, next, pc_idx}
			} else if m.y > 0 {
				world_menu_state = World_Menu_State_Top{i, true, pc_idx}
			}
		}
	}
}

update_world_menu_character :: proc(pc_idx: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top{0, true, pc_idx}
	} else {
		m := get_menu_input()
		pc_idx := pc_idx
		pc_idx += m.x
		if pc_idx < 0 {pc_idx = NUM_PC - 1}
		if pc_idx >= NUM_PC {pc_idx = 0}
		world_menu_state = World_Menu_State_Character{pc_idx}
	}
}

update_world_menu_skills :: proc(pc_idx: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top{1, true, pc_idx}
	}
}

update_world_menu_items :: proc(item_idx: int, targeting: bool, pc_idx: int) {
	if get_input(.CANCEL) {
		if targeting {
			world_menu_state = World_Menu_State_Items{item_idx, false, pc_idx}
		} else {
			world_menu_state = World_Menu_State_Top {
				i = 2,
			}
		}
	} else if get_input(.ENTER) {
		if targeting {
			item := item_data[item_idx]
			play_sound(.Warp) // todo
			item.effect(nil, get_pc(pc_idx), item.power)
			game_data.inventory[item_idx] -= 1
			if game_data.inventory[item_idx] == 0 {
				world_menu_state = World_Menu_State_Items{item_idx, false, pc_idx}
			}
			fmt.printfln("Used item %s", item.name)
		} else {
			world_menu_state = World_Menu_State_Items{item_idx, true, 0}
		}
	} else {
		if targeting {
			world_menu_state = World_Menu_State_Items{item_idx, true, change_world_menu_pc_dx_from_input(pc_idx)}
		} else {
			item_idx := item_idx
			m := get_menu_input()
			if m.y != 0 {
				item_idx += m.y
				if item_idx < 0 {item_idx = len(Item) - 1}
				if item_idx >= len(Item) {item_idx = 0}
				world_menu_state = World_Menu_State_Items{item_idx, targeting, pc_idx}
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
