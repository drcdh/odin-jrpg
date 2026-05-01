package game

import "core:strings"
import rl "vendor:raylib"

// This is loaded in `main` from `ATLAS_DATA`
atlas: rl.Texture

// This is manually constructed in `main` from the font info in `atlas.odin`
font: rl.Font

textures: map[string]rl.Texture

load_texture :: proc(path: string) -> rl.Texture {
	if t, t_ok := textures[path]; t_ok {
		return t
	}

	t := rl.LoadTexture(strings.clone_to_cstring(strings.concatenate({ASSETS_ROOT, path}), context.temp_allocator))

	if t.id != 0 {
		textures[path] = t
	}

	return t
}
