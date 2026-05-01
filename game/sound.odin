package game

import "core:strings"
import rl "vendor:raylib"

AUDIO_ASSETS_ROOT :: "game/audio/"


SoundName :: enum {
	UI_Blip,
}

sound_paths := [SoundName]string{
	.UI_Blip = "107156__bubaproducer__button-9-funny.wav",
}

sounds : map[SoundName]rl.Sound

get_sound :: proc(n: SoundName) -> rl.Sound {
	if s, ok := sounds[n]; ok {
		return s
	}

	path := sound_paths[n]

	s := rl.LoadSound(strings.clone_to_cstring(strings.concatenate({AUDIO_ASSETS_ROOT, path}, context.temp_allocator), context.temp_allocator))

	sounds[n] = s

	return s
}

play_sound :: proc(n: SoundName) {
	s := get_sound(n)
	rl.PlaySound(s)
}

unload_sounds :: proc() {
	for _, s in sounds {
		rl.UnloadSound(s)
	}
	delete(sounds)
}
