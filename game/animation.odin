// Adapted from Karl's atlas-builder example

// This implements animations using an atlased texture as defined in atlas.odin (which is generated
// before the code in this folder is built).
//
// These animations target a specific `Animation_Name` from atlas.odin. `animation_update` uses a
// timer to know when to switch to the next frame. It uses the duration in the texture, which may
// come from an aseprite frame.
//
// Use proc `animation_atlas_texture` to fetch the current frame's atlas texture, which you can
// then draw using:
// anim_texture := animation_atlas_texture(my_anim)
// rl.DrawTextureRec(atlas, anim_texture.rect, position, rl.WHITE)
//
// See main.odin for a more involved example of how to use the animation_atlas_texture proc.

package game

import rl "vendor:raylib"

Animation :: struct {
	atlas_anim: Animation_Name,
	current_frame: Texture_Name,
	timer: f32,
}

animation_create :: proc(anim: Animation_Name) -> Animation {
	a := atlas_animations[anim]

	return {
		current_frame = a.first_frame,
		atlas_anim = anim,
		timer = atlas_textures[a.first_frame].duration,
	}
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

	for i in aa.first_frame..=aa.last_frame {
		t := atlas_textures[i]
		l += t.duration
	}

	return l
}

animation_atlas_texture :: proc(anim: Animation) -> Atlas_Texture {
	return atlas_textures[anim.current_frame]
}

draw_animation :: proc(anim: Animation, pos: Pixel_Coord, tint: rl.Color, scale:f32=1, flip_x:=false) {
	// Fetch the texture for the current frame of the animation.
	anim_texture := animation_atlas_texture(anim)

	// The region inside atlas.png where this animation frame lives
	atlas_rect := anim_texture.rect

	// The texture has four offset fields: offset_top, right, bottom and left. The offsets records
	// the distance between the pixels in the atlas and the edge of the original document in the
	// image editing software. Since the atlas is tightly packed, any empty pixels are removed.
	// These offsets can be used to correct for that removal.
	//
	// This can be especially obvious in animations where different frames can have different
	// amounts of empty pixels around it. By adding the offsets everything will look OK.
	//
	// Note that when when flip_x is true we need to add the offset_right instead of the offset_left.
	offset := Pixel_Coord { anim_texture.offset_left, anim_texture.offset_top }

	// Flip player when walking to the left. This means both flipping the atlas_rect width, but also
	// using the right offset instead of the left one.
	if flip_x {
		atlas_rect.width = -atlas_rect.width
		offset.x = anim_texture.offset_right
	}

	// The dest rectangle tells us where on screen to draw the player.
	dest := Rect {
		pos.x + offset.x,
		pos.y + offset.y,
		scale*anim_texture.rect.width,
		scale*anim_texture.rect.height,
	}

	// I want origin of player to be at the feet.
	// Use document_size for origin instead of anim_texture.rect.width (and height), because those
	// may vary from frame to frame due to being tightly packed in atlas.
	origin := Pixel_Coord {
		// anim_texture.document_size.x/2,
		// anim_texture.document_size.y - 1, // -1 because there's an outline in the player anim that takes an extra pixel
	}

	// Draw texture. Note how we are drawing using the atlas but choosing a specific region in it
	// using atlas_rect.
	rl.DrawTexturePro(atlas, atlas_rect, dest, origin, 0, tint)
}
