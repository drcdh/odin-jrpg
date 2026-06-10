package game

import "core:thread"
import "core:time"
import rl "vendor:raylib"

SOUND_MAX_VOLUME :: 10
DEFAULT_MUSIC_VOLUME :: 7
DEFAULT_EFFECTS_VOLUME :: 10

music_volume := DEFAULT_MUSIC_VOLUME

MUSIC_ASSETS_ROOT :: "game/audio/"

Music_Name :: enum {
	None,
	Overworld,
	Town,
	Battle,
}

Music_Asset :: struct {
	filename: string,
	data:     []u8,
}

music := [Music_Name]Music_Asset {
	.None = {},
	.Overworld = {
		filename = "geoffharvey-finding-mithral-openworld-game-375527.mp3",
		data = #load("audio/geoffharvey-finding-mithral-openworld-game-375527.mp3"),
	},
	.Town = {filename = "phantasticbeats-rpg-city-8381.mp3", data = #load("audio/phantasticbeats-rpg-city-8381.mp3")},
	.Battle = {
		filename = "vespidaze-upbeat-rpg-battle-460971.mp3",
		data = #load("audio/vespidaze-upbeat-rpg-battle-460971.mp3"),
	},
}

Music_State :: struct {
	new_name:    Music_Name,
	cur_name:    Music_Name,
	cur:         rl.Music,
	run_thread:  bool,
	thread:      ^thread.Thread,
	cur_volume:  int,
	fade_music:  bool,
	fade_volume: f32,
}

get_music_volume :: proc(s: ^Music_State) -> f32 {
	return f32(s.cur_volume) / SOUND_MAX_VOLUME
}

// Taken from Cat & Onion by Karl Zylinski
// The music is played on a separate thread to avoid stutter in the music. Note that I communicate
// with this thread using only variables that are 64 bit or smaller, which is read and written
// atomically. That's why there are no mutexes between this thread and the main thread.
//
// The game is single threaded except for the music thread.
music_thread :: proc(t: ^thread.Thread) {
	s := (^Music_State)(t.data)
	for s.run_thread {
		if s.fade_music {
			s.fade_volume -= 0.003

			if s.fade_volume <= 0 {
				s.fade_volume = 0
				s.fade_music = false
				s.new_name = .None
			} else if rl.IsMusicStreamPlaying(s.cur) {
				rl.SetMusicVolume(s.cur, get_music_volume(s) * s.fade_volume)
			}
		} else if music_volume != s.cur_volume {
			s.cur_volume = music_volume

			if rl.IsMusicStreamPlaying(s.cur) {
				rl.SetMusicVolume(s.cur, get_music_volume(s))
			}
		}

		new_name := s.new_name
		if new_name != s.cur_name {
			rl.StopMusicStream(s.cur)
			rl.UnloadMusicStream(s.cur)
			s.cur = {}

			if new_name != .None {
				s.cur = load_music(new_name)
				s.cur.looping = true
				rl.PlayMusicStream(s.cur)
				rl.SetMusicVolume(s.cur, get_music_volume(s))
			}

			s.cur_name = new_name
		}

		rl.UpdateMusicStream(s.cur)
		time.sleep(10 * time.Millisecond)
	}

	rl.StopMusicStream(s.cur)
	rl.UnloadMusicStream(s.cur)
}

music_init :: proc(s: ^Music_State) {
	s.run_thread = true
	if s.thread = thread.create(music_thread); s.thread != nil {
		s.thread.init_context = context
		s.thread.data = rawptr(s)
		thread.start(s.thread)
	}
}

music_shutdown :: proc(s: ^Music_State) {
	s.run_thread = false
	thread.join(s.thread)
	thread.destroy(s.thread)
}

music_fade :: proc(s: ^Music_State) {
	s.fade_volume = 1
	s.fade_music = true
}

play_music :: proc(s: ^Music_State, m: Music_Name) {
	s.fade_music = false
	s.new_name = m
}

load_music :: proc(name: Music_Name) -> rl.Music {
	s := music[name]

	return rl.LoadMusicStreamFromMemory(".mp3", &s.data[0], i32(len(s.data)))
}
