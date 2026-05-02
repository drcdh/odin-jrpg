package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

World_Menu_Selection ::enum {
	Characters,
	Skills,
	Items,
	System,
}

world_menu_active : bool

world_menu_selection : World_Menu_Selection

world_menu_options := [4]string {
	"Characters",
	"Skills",
	"Items",
	"System",
}

TOP_MENU_HEIGHT :: 2*TILE_SIZE

icon : Animation

init_world_menu :: proc() {
	icon = animation_create(.Select_Icon)
}

draw_world_menu :: proc() {
	draw_menu({0, 0, f32(WINDOW_WIDTH), TOP_MENU_HEIGHT})
	x : f32 = 2*TILE_SIZE
	y := .5*TILE_SIZE
	for i in 0..<4 {
		if world_menu_selection == World_Menu_Selection(i) {
			draw_animation(icon, {x-1.5*TILE_SIZE, y}, rl.WHITE, SCALE)
		}
		rl.DrawTextEx(font, strings.clone_to_cstring(world_menu_options[i], context.allocator), {x, y}, 32, 0, rl.WHITE)
		x += f32(WINDOW_WIDTH/4)
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

CHARACTER_CARD_DIM :: Pixel_Dim{10*TILE_SIZE, 12*TILE_SIZE}
CHARACTER_CARD_TOP_LEFT :: Pixel_Coord{TILE_SIZE, TOP_MENU_HEIGHT+TILE_SIZE}
draw_world_menu_characters :: proc() {
	draw_menu({0, TOP_MENU_HEIGHT, f32(WINDOW_WIDTH), f32(WINDOW_HEIGHT)-TOP_MENU_HEIGHT})
	card := 0
	row : f32 = 0
	for i in 0..<NUM_PC {
		{//if character in party
			card_origin := CHARACTER_CARD_TOP_LEFT + {f32(card%3), row}*CHARACTER_CARD_DIM
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
	rl.DrawRectangleLinesEx({origin.x, origin.y, CHARACTER_CARD_DIM.x, CHARACTER_CARD_DIM.y}, 2, tint)
	pc := get_pc(pc)
	rl.DrawTextEx(font, pc.name, origin, 32, 0, rl.WHITE)

	texture_rect := atlas_textures[.Pc0].rect
	rl.DrawTextureRec(atlas, texture_rect, {origin.x + CHARACTER_CARD_DIM.x - TILE_SIZE - texture_rect.width, origin.y+32}, tint)

	stats_origin := Pixel_Coord{origin.x, origin.y+64}
	stats_font_size : f32 = 24
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
	if selection < 0 { selection = 3 }
	if selection >= 4 { selection = 0 }
	world_menu_selection = World_Menu_Selection(selection)
	animation_update(&icon, rl.GetFrameTime())
}
