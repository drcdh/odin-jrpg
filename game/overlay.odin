package game

import rl "vendor:raylib"

CLOUDS_DATA :: #load("textures/_overlay_clouds.png")

clouds: rl.Texture

clouds_offset: Pixel_Coord

overlay: bool

init_overlays :: proc() {
	clouds_image := rl.LoadImageFromMemory(".png", raw_data(CLOUDS_DATA), i32(len(CLOUDS_DATA)))
	clouds = rl.LoadTextureFromImage(clouds_image)
	rl.UnloadImage(clouds_image)

	clouds_offset = {0, 0}
}

draw_overlay :: proc() {
	if overlay {
		for nx in -1 ..= 1 {
			for ny in -1 ..= 1 {
				draw_texture(clouds, clouds_offset + {f32(nx) * zoom * 320, f32(ny) * zoom * 320}, {255, 255, 255, 50})
			}
		}
	}
}

update_overlay :: proc() {
	if overlay {
		dt := rl.GetFrameTime()
		clouds_offset += tile_to_pixel(.5, .2) * dt
		if clouds_offset.x >= zoom * 320 {clouds_offset.x -= zoom * 320}
		if clouds_offset.y >= zoom * 320 {clouds_offset.y -= zoom * 320}
		if clouds_offset.x < 0 {clouds_offset.x += zoom * 320}
		if clouds_offset.y < 0 {clouds_offset.y += zoom * 320}
	}
}
