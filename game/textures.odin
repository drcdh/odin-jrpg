package game

import "core:slice"
import rl "vendor:raylib"

ATLAS_DATA :: #load("atlas.png")
BATTLE_BACKGROUND_DATA :: #load("textures/_battle_background.png")
FONT_ATLAS_DATA :: #load("textures/_font.png")

Rect :: rl.Rectangle // for the results of atlas_builder

atlas: rl.Texture
battle_background: rl.Texture
font_atlas: rl.Texture

font: rl.Font

init_atlases :: proc() {
	atlas_image := rl.LoadImageFromMemory(".png", raw_data(ATLAS_DATA), i32(len(ATLAS_DATA)))
	atlas = rl.LoadTextureFromImage(atlas_image)
	rl.UnloadImage(atlas_image)

	bb_image := rl.LoadImageFromMemory(".png", raw_data(BATTLE_BACKGROUND_DATA), i32(len(BATTLE_BACKGROUND_DATA)))
	battle_background = rl.LoadTextureFromImage(bb_image)
	rl.UnloadImage(bb_image)

	font_atlas_image := rl.LoadImageFromMemory(".png", raw_data(FONT_ATLAS_DATA), i32(len(FONT_ATLAS_DATA)))
	font_atlas = rl.LoadTextureFromImage(font_atlas_image)
	rl.UnloadImage(font_atlas_image)

	// from Karl's atlas-builder example

	num_glyphs := len(atlas_glyphs)
	font_rects := make([]Rect, num_glyphs)
	glyphs := make([]rl.GlyphInfo, num_glyphs)

	for ag, idx in atlas_glyphs {
		font_rects[idx] = ag.rect
		glyphs[idx] = {
			value    = ag.value,
			offsetX  = i32(ag.offset_x),
			offsetY  = i32(ag.offset_y),
			advanceX = i32(ag.advance_x),
		}
	}

	font = {
		baseSize     = 8,
		glyphCount   = i32(num_glyphs),
		glyphPadding = 0,
		texture      = font_atlas,
		recs         = raw_data(font_rects),
		glyphs       = raw_data(glyphs),
	}
}

delete_atlased_font :: proc(font: rl.Font) {
	delete(slice.from_ptr(font.glyphs, int(font.glyphCount)))
	delete(slice.from_ptr(font.recs, int(font.glyphCount)))
}

draw_texture_atlas :: proc(v: Texture_Name, pos: Pixel_Coord, tint := rl.WHITE) {
	atlas_texture := atlas_textures[v]
	atlas_rect := atlas_texture.rect
	offset := Pixel_Coord{atlas_texture.offset_left, atlas_texture.offset_top}
	offset *= zoom
	dest := rl.Rectangle{pos.x + offset.x, pos.y + offset.y, zoom * atlas_rect.width, zoom * atlas_rect.height}
	rl.DrawTexturePro(atlas, atlas_rect, dest, {}, 0, tint)
}

draw_texture_rl :: proc(texture: rl.Texture, pos: Pixel_Coord, tint := rl.WHITE) {
	w := f32(texture.width)
	h := f32(texture.height)
	dest := rl.Rectangle{pos.x, pos.y, zoom * w, zoom * h}
	rl.DrawTexturePro(texture, {0, 0, w, h}, dest, {}, 0, tint)
}

draw_texture :: proc {
	draw_texture_atlas,
	draw_texture_rl,
}

draw_menu :: proc(l, t, w, h: Tile_T, tint := rl.WHITE) {
	r := l + w - 1
	b := t + h - 1
	draw_texture(Texture_Name.Menu_Topleft, tile_to_pixel({l, t}), tint)
	draw_texture(Texture_Name.Menu_Topright, tile_to_pixel({r, t}), tint)
	draw_texture(Texture_Name.Menu_Bottomleft, tile_to_pixel({l, b}), tint)
	draw_texture(Texture_Name.Menu_Bottomright, tile_to_pixel({r, b}), tint)
	for x in l + 1 ..< r {
		draw_texture(Texture_Name.Menu_Topcenter, tile_to_pixel({x, t}), tint)
		draw_texture(Texture_Name.Menu_Bottomcenter, tile_to_pixel({x, b}), tint)
		for y in t + 1 ..< b {
			draw_texture(Texture_Name.Menu_Center, tile_to_pixel({x, y}), tint)
		}
	}
	for y in t + 1 ..< b {
		draw_texture(Texture_Name.Menu_Centerleft, tile_to_pixel({l, y}), tint)
		draw_texture(Texture_Name.Menu_Centerright, tile_to_pixel({r, y}), tint)
	}
}

draw_text :: proc(l, t: f32, text: cstring, tint := rl.WHITE) {
	x := l * tile_size
	y := t * tile_size
	if x < 0 {x += view_dim.x}
	if y < 0 {y += view_dim.y}
	rl.DrawTextEx(font, text, {x, y}, tile_size / 2, 0, tint)
}
