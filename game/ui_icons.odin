package game

select_tile_icon: Sprite_State
select_tile_icon_down: Sprite_State
world_menu_icon: Sprite_State

init_ui_icons :: proc() {
	select_tile_icon = create_sprite_state(.Select_Tile)
	select_tile_icon_down = create_sprite_state(.Select_Tile_Down)
	world_menu_icon = create_sprite_state(.Select_Icon_Small)
}

update_ui_icons :: proc(dt: f32) {
	update_sprite(dt, &select_tile_icon)
	update_sprite(dt, &select_tile_icon_down)
	update_sprite(dt, &world_menu_icon)
}

draw_text_icon_f32 :: proc(i, j: f32, origin := [2]f32{}) {
	draw_sprite(world_menu_icon, tile_to_pixel(origin.x + i, origin.y + j))
}

draw_text_icon_Tile_Coord :: proc(i, j: f32, origin := Tile_Coord{}) {
	draw_text_icon_f32(i, j, {f32(origin.x), f32(origin.y)})
}

draw_text_icon :: proc {
	draw_text_icon_f32,
	draw_text_icon_Tile_Coord,
}

draw_tile_indicator_f32 :: proc(i, j: f32, origin := [2]f32{}) {
	draw_sprite(select_tile_icon, tile_to_pixel(origin.x + i, origin.y + j))
}

draw_tile_indicator_down_f32 :: proc(i, j: f32, origin := [2]f32{}) {
	draw_sprite(select_tile_icon_down, tile_to_pixel(origin.x + i, origin.y + j))
}
