package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

World_Menu_Selection :: enum {
	Characters,
	Skills,
	Items,
	System,
}

world_menu_active: bool

world_menu_selection: World_Menu_Selection

world_menu_options := [4]string{"Characters", "Skills", "Items", "System"}

world_menu_icon: Animation

init_world_menu :: proc() {
	world_menu_icon = animation_create(.Select_Icon_Small)
}

draw_world_menu :: proc() {
	draw_menu(0, 0, VIEW_TILES_W, 2)
	x: f32 = 1 * tile_size
	y: f32 = .75 * tile_size
	rl.DrawTextEx(font,
		strings.clone_to_cstring("Characters    Skills        Items         System", allocator=context.temp_allocator),
		{x, y},
		tile_size/2,
		0,
		rl.WHITE,
	)
	draw_animation(world_menu_icon, {(.5+ f32(world_menu_selection) * 4) * tile_size, y}, rl.WHITE)

	switch world_menu_selection {
	case .Characters:
		draw_world_menu_characters()
	case .Skills:
		draw_world_menu_skills()
	case .Items:
		draw_world_menu_items()
	case .System:
		draw_world_menu_system()
	}
}

draw_world_menu_characters :: proc() {
	draw_menu(0, 2, VIEW_TILES_W, VIEW_TILES_H - 2)
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
		}
	}
}

draw_character_card :: proc(pc: PC, origin: Pixel_Coord) {
	tint := pc_idle_anim_tint[pc]
	// rl.DrawRectangleLinesEx({origin.x, origin.y, 5 * tile_size, 6 * tile_size}, 2, tint)
	pc := get_pc(pc)
	rl.DrawTextEx(font, pc.name, origin, 32, 0, rl.WHITE)

	draw_texture(.Protagonist_Battle0, {origin.x + 3 * tile_size, origin.y}, tint)

	stats_origin := Pixel_Coord{origin.x, origin.y + 2*tile_size}
	stats_font_size: f32 = 24
	for i in 0 ..< NUM_STATS {
		rl.DrawTextEx(
			font,
			strings.clone_to_cstring(stat_string(pc^, Stat(i)), context.temp_allocator),
			stats_origin + {0, f32(i) * stats_font_size},
			stats_font_size,
			0,
			rl.WHITE,
		)
	}
	// rl.DrawTextEx(
	// 	font,
	// 	fmt.caprintf("HP: %d", pc.stats.hitpoints, allocator = context.temp_allocator),
	// 	stats_origin,
	// 	stats_font_size,
	// 	0,
	// 	rl.WHITE,
	// )
	// stats_origin.y += stats_font_size
	// rl.DrawTextEx(
	// 	font,
	// 	fmt.caprintf("Offense: %d", pc.stats.offense, allocator = context.temp_allocator),
	// 	stats_origin,
	// 	stats_font_size,
	// 	0,
	// 	rl.WHITE,
	// )
	// stats_origin.y += stats_font_size
	// rl.DrawTextEx(
	// 	font,
	// 	fmt.caprintf("Defense: %d", pc.stats.defense, allocator = context.temp_allocator),
	// 	stats_origin,
	// 	stats_font_size,
	// 	0,
	// 	rl.WHITE,
	// )
}

draw_world_menu_skills :: proc() {}

draw_world_menu_items :: proc() {}

draw_world_menu_system :: proc() {}

update_world_menu :: proc() {
	m := get_menu_input()
	selection := m.x + int(world_menu_selection)
	if selection < 0 {selection = 3}
	if selection >= 4 {selection = 0}
	world_menu_selection = World_Menu_Selection(selection)
	animation_update(&world_menu_icon, rl.GetFrameTime())
}
