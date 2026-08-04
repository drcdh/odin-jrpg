package game

select_tile_icon: Animation
select_tile_icon_down: Animation
world_menu_icon: Animation

init_ui_icons :: proc() {
	select_tile_icon = animation_create(.Select_Tile)
	select_tile_icon_down = animation_create(.Select_Tile_Down)
	world_menu_icon = animation_create(.Select_Icon_Small)
}

update_ui_icons :: proc(dt: f32) {
	animation_update(&select_tile_icon, dt)
	animation_update(&select_tile_icon_down, dt)
	animation_update(&world_menu_icon, dt)
}

draw_text_icon_f32 :: proc(i, j: f32, origin := [2]f32{}) {
	draw_animation(world_menu_icon, tile_to_pixel(origin.x + i, origin.y + j))
}

draw_text_icon_Tile_Coord :: proc(i, j: f32, origin := Tile_Coord{}) {
	draw_text_icon_f32(i, j, {f32(origin.x), f32(origin.y)})
}

draw_text_icon :: proc {
	draw_text_icon_f32,
	draw_text_icon_Tile_Coord,
}

draw_tile_indicator_f32 :: proc(i, j: f32, origin := [2]f32{}) {
	draw_animation(select_tile_icon, tile_to_pixel(origin.x + i, origin.y + j))
}

draw_tile_indicator_down_f32 :: proc(i, j: f32, origin := [2]f32{}) {
	draw_animation(select_tile_icon_down, tile_to_pixel(origin.x + i, origin.y + j))
}
