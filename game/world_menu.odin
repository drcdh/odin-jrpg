package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

World_Menu_State_Top :: struct {i: int, next: bool, pc_idx: int}
World_Menu_State_Character :: struct {pc_idx: int }
World_Menu_State_Skills :: struct {pc_idx: int }
World_Menu_State_Items :: struct {i: int}
World_Menu_State_System :: struct {i: int}

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
		draw_world_menu_items(state.i)
	case World_Menu_State_System:
		draw_world_menu_top(3, true, 0, rl.GRAY)
		draw_world_menu_system(state.i)
	}
	rl.DrawText(fmt.caprint(world_menu_state, allocator=context.temp_allocator), i32(tile_size), i32(view_dim.y-tile_size), 32, rl.PURPLE)
}

draw_world_menu_top :: proc(i: int, next: bool, pc_idx: int, tint := rl.WHITE) {
	draw_menu(0, 0, VIEW_TILES_W, 2, tint)
	x: f32 = 1 * tile_size
	y: f32 = .75 * tile_size
	rl.DrawTextEx(
		font,
		strings.clone_to_cstring("Characters    Skills        Items         System", allocator = context.temp_allocator),
		{x, y},
		tile_size / 2,
		0,
		tint,
	)

	if !next {
		draw_animation(world_menu_icon, {(.5 + f32(i) * 4) * tile_size, y}, tint)
	}

	draw_menu(0, 2, VIEW_TILES_W, VIEW_TILES_H - 2, tint)
	card := 0
	row: f32 = 0
	for i in 0 ..< NUM_PC {
		{ 	//if character in party
			card_origin :=
				Pixel_Coord{tile_size, 3 * tile_size} + {f32(card % 3), row} * Pixel_Coord{5 * tile_size, 5 * tile_size}
			draw_character_card(PC(i), card_origin)
			card += 1
			if i == 2 {
				card = 0
				row += 1
			}
			if next && i == pc_idx {
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

	draw_texture(.Protagonist_Battle0, {origin.x + 3 * tile_size, origin.y}, tint)

	stats_origin := Pixel_Coord{origin.x, origin.y + 2 * tile_size}
	stats_font_size: f32 = 24
	for i in 0 ..< NUM_STATS {
		rl.DrawTextEx(
			font,
			strings.clone_to_cstring(stat_string(pc^, Stat(i)), context.temp_allocator),
			stats_origin + {0, f32(i) * stats_font_size},
			stats_font_size,
			0,
			tint,
		)
	}
}

draw_world_menu_character :: proc(pc_idx: int) {
	draw_menu(1, 1, VIEW_TILES_W-2, VIEW_TILES_H-2)
}

draw_world_menu_skills :: proc(pc_idx: int) {
	draw_menu(1, 1, VIEW_TILES_W-2, VIEW_TILES_H-2)
}

draw_world_menu_items :: proc(i: int) {
	draw_menu(1, 1, VIEW_TILES_W-2, VIEW_TILES_H-2)
}

draw_world_menu_system :: proc(i: int) {
	draw_menu(1, 1, VIEW_TILES_W-2, VIEW_TILES_H-2)
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
		update_world_menu_items(state.i)
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
			world_menu_state = World_Menu_State_Character{pc_idx}
		} else {
			m := get_menu_input()
			pc_idx := pc_idx
			if m.x > 0 {
				if pc_idx == 2 || pc_idx == 5 { pc_idx -= 2 } else { pc_idx += 1 }
			} else if m.x < 0 {
				if pc_idx == 0 || pc_idx == 3 { pc_idx += 2 } else { pc_idx -= 1 }
			}
			if m.y != 0 {
				if pc_idx < 3 { pc_idx += 3 } else { pc_idx -= 3 }
			}
			world_menu_state = World_Menu_State_Top{i, true, pc_idx}
		}
	} else {
		if get_input(.CANCEL) {
			world_menu_active = false
		} else if get_input(.ENTER) {
			switch i {
			case 0..=1:
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
	}
}

update_world_menu_skills :: proc(pc_idx: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top{1, true, pc_idx}
	}
}

update_world_menu_items :: proc(i: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top{i=2}
	}
}

update_world_menu_system :: proc(i: int) {
	if get_input(.CANCEL) {
		world_menu_state = World_Menu_State_Top{i=3}
	}
}
