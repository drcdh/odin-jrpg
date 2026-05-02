// Adapted from Karl's atlas-builder example

package game

import rl "vendor:raylib"

Animation :: struct {
	atlas_anim:    Animation_Name,
	current_frame: Texture_Name,
	timer:         f32,
}

animation_create :: proc(anim: Animation_Name) -> Animation {
	a := atlas_animations[anim]

	return {current_frame = a.first_frame, atlas_anim = anim, timer = atlas_textures[a.first_frame].duration}
}

animation_update :: proc(a: ^Animation, dt: f32) -> bool {
	a.timer -= dt
	looped := false

	if a.timer <= 0 {
		a.current_frame = Texture_Name(int(a.current_frame) + 1)
		anim := atlas_animations[a.atlas_anim]

		if a.current_frame > anim.last_frame {
			a.current_frame = anim.first_frame
			looped = true
		}

		a.timer = atlas_textures[a.current_frame].duration
	}

	return looped
}

animation_length :: proc(anim: Animation_Name) -> f32 {
	l: f32
	aa := atlas_animations[anim]

	for i in aa.first_frame ..= aa.last_frame {
		t := atlas_textures[i]
		l += t.duration
	}

	return l
}

animation_atlas_texture :: proc(anim: Animation) -> Atlas_Texture {
	return atlas_textures[anim.current_frame]
}

draw_animation :: proc(anim: Animation, pos: Pixel_Coord, tint: rl.Color, flip_x := false) {
	anim_texture := animation_atlas_texture(anim)

	atlas_rect := anim_texture.rect

	offset := Pixel_Coord{anim_texture.offset_left, anim_texture.offset_top}

	if flip_x {
		atlas_rect.width = -atlas_rect.width
		offset.x = anim_texture.offset_right
	}

	dest := Rect{pos.x + offset.x, pos.y + offset.y, SCALE * anim_texture.rect.width, SCALE * anim_texture.rect.height}

	rl.DrawTexturePro(atlas, atlas_rect, dest, {}, 0, tint)
}
