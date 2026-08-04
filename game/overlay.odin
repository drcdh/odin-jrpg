package game

import hm "core:container/handle_map"
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
				draw_texture(clouds, clouds_offset + {f32(nx) * zoom * 320, f32(ny) * zoom * 320}, rl.Color{255, 255, 255, 50})
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

darkness_texture: rl.RenderTexture
darkness: u8

init_darkness :: proc() {
	darkness_texture = rl.LoadRenderTexture(i32(view_dim.x), i32(view_dim.y))
}

delete_darkness :: proc() {
	rl.UnloadRenderTexture(darkness_texture)
}

draw_darkness :: proc() {
	if darkness > 0 {
		rl.BeginTextureMode(darkness_texture)
		rl.ClearBackground(rl.BLANK)
		if camera := get_world_entity(camera_handle); camera != nil {
			it := hm.iterator_make(&world_entities.entities)
			for e, _ in hm.iterate(&it) {
				if e.light > 0 {
					pos := get_entity_pixel(e^) - get_entity_pixel(camera^) + view_dim / 2
					radius := f32(e.light) * tile_size
					rl.DrawCircleV(pos, radius, rl.WHITE)
				}
			}
		}
		rl.BeginBlendMode(.SUBTRACT_COLORS)
		rl.DrawRectangleV({0, 0}, view_dim, rl.BLACK)
		rl.EndBlendMode()
		rl.EndTextureMode()
	}
	rect := rl.Rectangle{0, 0, view_dim.x, -view_dim.y}
	rl.DrawTexturePro(darkness_texture.texture, rect, rect, {}, 0, {255, 255, 255, darkness})
}
