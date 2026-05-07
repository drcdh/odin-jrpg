package game

import "core:slice"
import rl "vendor:raylib"

ATLAS_DATA :: #load("atlas.png")

Rect :: rl.Rectangle // for the results of atlas_builder

TEXT_COLOR := rl.Color{50, 10, 10, 255}

// This is loaded in `main` from `ATLAS_DATA`
atlas: rl.Texture

// This is manually constructed in `main` from the font info in `atlas.odin`
font: rl.Font

// from Karl's atlas-builder example
load_atlased_font :: proc() -> rl.Font {
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

	return {
		baseSize = ATLAS_FONT_SIZE,
		glyphCount = i32(num_glyphs),
		glyphPadding = 0,
		texture = atlas,
		recs = raw_data(font_rects),
		glyphs = raw_data(glyphs),
	}
}

delete_atlased_font :: proc(font: rl.Font) {
	delete(slice.from_ptr(font.glyphs, int(font.glyphCount)))
	delete(slice.from_ptr(font.recs, int(font.glyphCount)))
}

draw_texture :: proc(v: Texture_Name, pos: Pixel_Coord, tint: rl.Color) {
	atlas_texture := atlas_textures[v]
	atlas_rect := atlas_texture.rect
	offset := Pixel_Coord{atlas_texture.offset_left, atlas_texture.offset_top}
	offset *= zoom
	dest := rl.Rectangle{pos.x +offset.x, pos.y + offset.y, zoom * atlas_rect.width, zoom * atlas_rect.height}
	rl.DrawTexturePro(atlas, atlas_rect, dest, {}, 0, tint)
}
