package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

Sprite_Tag :: enum {
	Left,
	Down,
	Right,
	Up,
	Active,
	Inactive,
	Closed,
	Opened,
	Idle,
	Walk,
	LArm,
	RArm,
	Cheer,
	Kneeled,
	Downed,
}

Sprite_Type :: enum {
	Static,
	Anim,
	Tagged,
}

Sprite_Metadata :: struct {
	filename:   string,
	frame_size: Pixel_Dim,
	type:       Sprite_Type,
	tags:       []Sprite_Tag,
	num_frames: []u16,
	frame_t:    f32,
}

Sprite :: struct {
	name:   Sprite_Name, // can get metadata from this
	img_h:  Image_Handle, // will be different from Sprites with same Sprite_Name if palette-swapped
	handle: Sprite_Handle,
}

Image :: struct {
	texture: rl.Texture,
	handle:  Image_Handle,
}

Color_Swap :: struct {
	from, to: rl.Color,
}

Palette_Swap :: []Color_Swap

Image_Handle :: hm.Handle32
Sprite_Handle :: hm.Handle32

image_hm: hm.Dynamic_Handle_Map(Image, Image_Handle)
sprite_hm: hm.Dynamic_Handle_Map(Sprite, Sprite_Handle)

sprite_handles: map[Sprite_Name]Sprite_Handle

init_sprites :: proc() {
	hm.dynamic_init(&image_hm, context.allocator)
	hm.dynamic_init(&sprite_hm, context.allocator)
}

delete_sprites :: proc() {
	hm.dynamic_destroy(&image_hm)
	hm.dynamic_destroy(&sprite_hm)
	clear(&sprite_handles)
	delete(sprite_handles)
}

load_sprite :: proc(n: Sprite_Name, p: Palette_Swap = {}) -> (sprite: Sprite) {
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)

	m := sprite_metadata[n]
	filepath := fmt.caprintf("./game/sprites/%s.png", m.filename); defer delete(filepath)
	img := rl.LoadImage(filepath); defer rl.UnloadImage(img)

	if len(p) > 0 {
		fmt.printfln("Processing palette swap with %d colors", len(p))
		for cs in p {
			rl.ImageColorReplace(&img, cs.from, cs.to)
		}
	}
	texture := rl.LoadTextureFromImage(img)

	sprite.name = n
	sprite.img_h = hm.add(&image_hm, Image{texture = texture})

	time.stopwatch_stop(&stopwatch)

	fmt.printfln("Loaded sprite %s in %s", n, time.stopwatch_duration(stopwatch))
	return
}

get_sprite_h :: proc(n: Sprite_Name, p: Palette_Swap = {}) -> Sprite_Handle {
	if p == nil {
		if h, exists := sprite_handles[n]; exists {
			fmt.printfln("Sprite %s previously loaded. Getting from hm", n)
			return h
		}
	}
	sprite := load_sprite(n, p)
	new_h := hm.add(&sprite_hm, sprite)
	sprite_handles[n] = new_h
	return new_h
}

Sprite_State :: struct {
	h:      Sprite_Handle,
	tint:   rl.Color,
	tag:    Sprite_Tag,
	frame:  u16,
	frozen: bool,
	t:      f32,
}

create_sprite_state :: proc(n: Sprite_Name, t: Maybe(Sprite_Tag) = nil, p: Palette_Swap = {}) -> (s: Sprite_State) {
	fmt.printfln("\nCreating new sprite state for %s", n)
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)

	s.h = get_sprite_h(n, p)
	s.tint = rl.WHITE

	metadata := sprite_metadata[n]
	if metadata.type == .Tagged {
		s.tag = t.? if t != nil else metadata.tags[0]
	}

	time.stopwatch_stop(&stopwatch)
	fmt.printfln("Took %s", time.stopwatch_duration(stopwatch))
	return
}

@(private = "file")
find_tag :: proc(tags: []Sprite_Tag, tag: Sprite_Tag) -> int {
	for p, i in tags {
		if p == tag {
			return i
		}
	}
	return 0
}

draw_sprite :: proc(state: Sprite_State, pos: Pixel_Coord, tint := rl.WHITE) {
	if sprite := hm.get(&sprite_hm, state.h); sprite != nil {
		image := hm.get(&image_hm, sprite.img_h)
		m := sprite_metadata[sprite.name]
		tags := m.tags
		i_tag := find_tag(tags, state.tag)
		src := [2]f32{f32(state.frame), f32(i_tag)} * m.frame_size
		draw_texture_rl_src(
			image.texture,
			{src.x, src.y, m.frame_size.x, m.frame_size.y},
			pos,
			rl.ColorTint(state.tint, tint),
		)
	}
}

update_sprite :: proc(dt: f32, state: ^Sprite_State) -> bool {
	if sprite := hm.get(&sprite_hm, state.h); sprite != nil {
		m := sprite_metadata[sprite.name]
		if m.type == .Static {return false}
		if !state.frozen {
			state.t += dt
			if state.t >= m.frame_t / 1000 {
				state.t = 0
				tag_idx := find_tag(m.tags, state.tag)
				state.frame = (state.frame + 1) %% m.num_frames[tag_idx]
				return state.frame == 0 // looped
			}
		}
	}
	return false
}

freeze_sprite :: proc(state: ^Sprite_State, frame: u16) {
	state.frame = frame
	state.frozen = true
}

unfreeze_sprite :: proc(state: ^Sprite_State) {
	state.frozen = false
}

get_sprite_tag :: proc(state: Sprite_State) -> Sprite_Tag {
	return state.tag
}

set_sprite_tag :: proc(state: ^Sprite_State, tag: Sprite_Tag) {
	state.tag = tag
	// state.frame = 0
	// state.t = 0

}

raw_sprite_size_name :: proc(name: Sprite_Name) -> Pixel_Dim {
	return sprite_metadata[name].frame_size
}

raw_sprite_size_state :: proc(state: Sprite_State) -> Pixel_Dim {
	sprite := hm.get(&sprite_hm, state.h)
	return sprite_metadata[sprite.name].frame_size
}

raw_sprite_size :: proc {
	raw_sprite_size_name,
	raw_sprite_size_state,
}

sprite_size_name :: proc(name: Sprite_Name) -> Pixel_Dim {
	return {zoom, zoom} * raw_sprite_size_name(name)
}

sprite_size_state :: proc(state: Sprite_State) -> Pixel_Dim {
	return {zoom, zoom} * raw_sprite_size_state(state)
}

sprite_size :: proc {
	sprite_size_name,
	sprite_size_state,
}
