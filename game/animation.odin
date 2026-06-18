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

draw_animation :: proc(anim: Animation, pos: Pixel_Coord, tint := rl.WHITE, flip_x := false) {
	anim_texture := animation_atlas_texture(anim)

	atlas_rect := anim_texture.rect

	offset := Pixel_Coord{anim_texture.offset_left, anim_texture.offset_top}

	if flip_x {
		atlas_rect.width = -atlas_rect.width
		offset.x = anim_texture.offset_right
	}

	offset *= zoom

	dest := Rect{pos.x + offset.x, pos.y + offset.y, zoom * anim_texture.rect.width, zoom * anim_texture.rect.height}

	// debug
	// rl.DrawRectangleLinesEx(dest, 2, rl.RED)
	// rl.DrawLineEx({pos.x, pos.y}, {pos.x + tile_size, pos.y}, 1, rl.BLUE)
	// rl.DrawLineEx({pos.x, pos.y}, {pos.x, pos.y + tile_size}, 1, rl.BLUE)
	// end debug

	rl.DrawTexturePro(atlas, atlas_rect, dest, {}, 0, tint)
}

Facing_Animation :: struct {
	left:  Animation,
	right: Animation,
	up:    Animation,
	down:  Animation,
	face:  Face,
}

facing_animation_create :: proc(
	left: Animation_Name,
	right: Animation_Name,
	up: Animation_Name,
	down: Animation_Name,
	face := Face.Down,
) -> Facing_Animation {
	left := animation_create(left)
	right := animation_create(right)
	up := animation_create(up)
	down := animation_create(down)
	return {face = face, left = left, right = right, up = up, down = down}
}

facing_animation_update :: proc(a: ^Facing_Animation, face: Face, dt: f32) {
	animation_update(&a.left, dt)
	animation_update(&a.right, dt)
	animation_update(&a.up, dt)
	animation_update(&a.down, dt)
	a.face = face
}

draw_facing_animation :: proc(anim: Facing_Animation, pos: Pixel_Coord, tint: rl.Color, flip_x := false) {
	switch anim.face {
	case .Left:
		draw_animation(anim.left, pos, tint, flip_x)
	case .Right:
		draw_animation(anim.right, pos, tint, flip_x)
	case .Down:
		draw_animation(anim.down, pos, tint, flip_x)
	case .Up:
		draw_animation(anim.up, pos, tint, flip_x)
	}
}
