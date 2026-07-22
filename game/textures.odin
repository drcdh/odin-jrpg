package game

import "core:slice"
import rl "vendor:raylib"

ATLAS_DATA :: #load("atlas.png")
BATTLE_BACKGROUND_DATA :: #load("textures/_battle_background.png")
FONT_ATLAS_DATA :: #load("textures/_font.png")
PANE_IMAGE_DATA :: #load("textures/_pane.png")

Rect :: rl.Rectangle // for the results of atlas_builder

atlas: rl.Texture
battle_background: rl.Texture
font_atlas: rl.Texture
pane_texture: rl.Texture

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

	pane_image := rl.LoadImageFromMemory(".png", raw_data(PANE_IMAGE_DATA), i32(len(PANE_IMAGE_DATA)))
	pane_texture = rl.LoadTextureFromImage(pane_image)
	rl.UnloadImage(pane_image)

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

draw_texture_chunk :: proc(v: Texture_Name, pos: Pixel_Coord, tint := rl.WHITE) {
	atlas_texture := atlas_textures[v]
	atlas_rect := atlas_texture.rect
	atlas_rect.width = TILE_SIZE
	atlas_rect.height = TILE_SIZE
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

draw_texture_rl_src :: proc(texture: rl.Texture, src: rl.Rectangle, pos: Pixel_Coord, tint := rl.WHITE) {
	w := src.width
	h := src.height
	dest := rl.Rectangle{pos.x, pos.y, zoom * w, zoom * h}
	rl.DrawTexturePro(texture, src, dest, {}, 0, tint)
}

draw_texture :: proc {
	draw_texture_atlas,
	draw_texture_rl,
	draw_texture_rl_src,
}

Pane_Piece :: enum {
	Top_Left,
	Top,
	Top_Right,
	Left,
	Right,
	Bottom_Left,
	Bottom,
	Bottom_Right,
}

PANE_BACKGROUND_COLOR :: rl.Color{1, 87, 155, 255}

draw_pane_piece :: proc(piece: Pane_Piece, l, t: Tile_T) {
	src := rl.Rectangle{0, 0, TILE_SIZE, TILE_SIZE}
	switch piece {
	case .Top_Left:
	case .Top:
		src.x = 16
	case .Top_Right:
		src.x = 32
	case .Left:
		src.y = 16
	case .Right:
		src.x = 32
		src.y = 16
	case .Bottom_Left:
		src.y = 32
	case .Bottom:
		src.x = 16
		src.y = 32
	case .Bottom_Right:
		src.x = 32
		src.y = 32
	}
	draw_texture(pane_texture, src, tile_to_pixel(l, t))
}

draw_pane_lt :: proc(l, t, w, h: Tile_T) {
	inside_pos := tile_to_pixel(l + 1, t + 1)
	inside_dim := tile_to_pixel(w - 2, h - 2)
	if inside_dim.x > 0 && inside_dim.y > 0 {
		rl.DrawRectangleV(inside_pos, inside_dim, PANE_BACKGROUND_COLOR)
	}
	r := l + w - 1
	b := t + h - 1
	draw_pane_piece(.Top_Left, l, t)
	draw_pane_piece(.Top_Right, r, t)
	draw_pane_piece(.Bottom_Left, l, b)
	draw_pane_piece(.Bottom_Right, r, b)
	for x in l + 1 ..< r {
		draw_pane_piece(.Top, x, t)
		draw_pane_piece(.Bottom, x, b)
	}
	for y in t + 1 ..< b {
		draw_pane_piece(.Left, l, y)
		draw_pane_piece(.Right, r, y)
	}
}

draw_pane_00 :: proc(w, h: Tile_T) {
	draw_pane_lt(0, 0, w, h)
}

draw_pane_alt :: proc(wh: Tile_Coord) {
	draw_pane_00(wh.x, wh.y)
}

draw_pane :: proc {
	draw_pane_00,
	draw_pane_lt,
	draw_pane_alt,
}

draw_text :: proc(l, t: f32, text: cstring, tint := rl.WHITE) {
	x := l * tile_size
	y := t * tile_size
	if x < 0 {x += view_dim.x}
	if y < 0 {y += view_dim.y}
	rl.DrawTextEx(font, text, {x, y}, tile_size / 2, 0, tint)
}

draw_text_center :: proc(l, t: f32, text: cstring, tint := rl.WHITE) {
	draw_text(l - f32(len(text)) / 4, t, text, tint)
}

draw_text_rjust :: proc(l, t: f32, text: cstring, tint := rl.WHITE) {
	draw_text(l - f32(len(text)) / 2, t, text, tint)
}
