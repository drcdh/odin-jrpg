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
	world_menu_icon = animation_create(.Select_Icon_Circle)
}

draw_world_menu :: proc() {
	draw_menu({view_origin.x, view_origin.y, view_dim.x, 2*tile_size})
	x: f32 = 2 * tile_size
	y: f32 = .5 * tile_size
	for i in 0 ..< 4 {
		if world_menu_selection == World_Menu_Selection(i) {
			draw_animation(world_menu_icon, {x - 1.5 * tile_size, y}, rl.WHITE)
		}
		rl.DrawTextEx(font, strings.clone_to_cstring(world_menu_options[i], context.allocator), {x, y}, 32, 0, rl.WHITE)
		x += view_dim.x / 4
	}

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
	draw_menu({0, 2*tile_size, view_dim.x, view_dim.y - 2*tile_size})
	card := 0
	row: f32 = 0
	for i in 0 ..< NUM_PC {
		{ 	//if character in party
			card_origin := Pixel_Coord{tile_size, 3*tile_size} + {f32(card % 3), row} * Pixel_Coord{5 * tile_size, 6 * tile_size}
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
	rl.DrawRectangleLinesEx({origin.x, origin.y, 5 * tile_size, 6 * tile_size}, 2, tint)
	pc := get_pc(pc)
	rl.DrawTextEx(font, pc.name, origin, 32, 0, rl.WHITE)

	texture_rect := atlas_textures[.Pc0].rect
	rl.DrawTextureRec(
		atlas,
		texture_rect,
		{origin.x + 5*tile_size - tile_size - texture_rect.width, origin.y + 32},
		tint,
	)

	stats_origin := Pixel_Coord{origin.x, origin.y + 64}
	stats_font_size: f32 = 24
	rl.DrawTextEx(font, fmt.caprintf("HP: %d", pc.stats.hitpoints), stats_origin, stats_font_size, 0, rl.WHITE)
	stats_origin.y += stats_font_size
	rl.DrawTextEx(font, fmt.caprintf("Offense: %d", pc.stats.offense), stats_origin, stats_font_size, 0, rl.WHITE)
	stats_origin.y += stats_font_size
	rl.DrawTextEx(font, fmt.caprintf("Defense: %d", pc.stats.defense), stats_origin, stats_font_size, 0, rl.WHITE)
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
