package game

import "core:strings"
import rl "vendor:raylib"

AUDIO_ASSETS_ROOT :: "game/audio/"


Sound_Name :: enum {
	UI_Blip,
	UI_Blip2,
	Whack,
}

sound_paths := [Sound_Name]string{
	.UI_Blip = "sfx_menu_move2.wav",
	.UI_Blip2 = "107156__bubaproducer__button-9-funny.wav",
	.Whack = "sfx_sounds_impact1.wav",
}

sounds : map[Sound_Name]rl.Sound

get_sound :: proc(n: Sound_Name) -> rl.Sound {
	if s, ok := sounds[n]; ok {
		return s
	}

	path := sound_paths[n]

	s := rl.LoadSound(strings.clone_to_cstring(strings.concatenate({AUDIO_ASSETS_ROOT, path}, context.temp_allocator), context.temp_allocator))

	sounds[n] = s

	return s
}

play_sound :: proc(n: Sound_Name) {
	s := get_sound(n)
	rl.PlaySound(s)
}

unload_sounds :: proc() {
	for _, s in sounds {
		rl.UnloadSound(s)
	}
	delete(sounds)
}
