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

_Sprite_Metadata_Static :: struct {}

_Sprite_Metadata_Anim :: struct {
	num_frames: u16,
	frame_t:    f32,
}

_Sprite_Metadata_Tagged :: struct {
	tags:       []Sprite_Tag,
	num_frames: []u16,
	frame_t:    f32,
}

_Sprite_Metadata :: union {
	_Sprite_Metadata_Static,
	_Sprite_Metadata_Anim,
	_Sprite_Metadata_Tagged,
}

Sprite_Metadata :: struct {
	filename:   string,
	frame_size: [2]f32,
	metadata:   _Sprite_Metadata,
}

Sprite :: struct {
	name:   Sprite_Name, // can get metadata from this
	image:  Image_Handle, // will be different from Sprites with same Sprite_Name if palette-swapped
	handle: Sprite_Handle,
}

Image :: struct {
	texture: rl.Texture,
	handle:  Image_Handle,
}

Palette_Swap :: struct {
	from: []rl.Color,
	to:   []rl.Color,
}

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

load_sprite :: proc(n: Sprite_Name, p: Maybe(Palette_Swap) = nil) -> (v: Sprite) {
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)

	m := sprite_metadata[n]
	filepath := fmt.caprintf("./game/sprites/%s.png", m.filename); defer delete(filepath)
	img := rl.LoadImage(filepath); defer rl.UnloadImage(img)
	texture := rl.LoadTextureFromImage(img)
	// TODO: palette swap
	v.name = n
	v.image = hm.add(&image_hm, Image{texture = texture})

	time.stopwatch_stop(&stopwatch)

	fmt.printfln("Loaded sprite %s in %s", n, time.stopwatch_duration(stopwatch))
	return
}

get_sprite_h :: proc(n: Sprite_Name, p: Maybe(Palette_Swap) = nil) -> Sprite_Handle {
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

_Sprite_State_Static :: struct {}

_Sprite_State_Anim :: struct {
	frame:  u16,
	frozen: bool,
	t:      f32,
}

_Sprite_State_Tagged :: struct {
	tag:    Sprite_Tag,
	frame:  u16,
	frozen: bool,
	t:      f32,
}

_Sprite_State :: union {
	_Sprite_State_Static,
	_Sprite_State_Anim,
	_Sprite_State_Tagged,
}

Sprite_State :: struct {
	h:       Sprite_Handle,
	tint:    rl.Color,
	variant: _Sprite_State,
}

create_sprite_state :: proc(
	n: Sprite_Name,
	t: Maybe(Sprite_Tag) = nil,
	p: Maybe(Palette_Swap) = nil,
) -> (
	s: Sprite_State,
) {
	fmt.printfln("\nCreating new sprite state for %s", n)
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)

	sprite_h := get_sprite_h(n, p)
	switch metadata in sprite_metadata[n].metadata {
	case _Sprite_Metadata_Static:
		s = Sprite_State {
			h       = sprite_h,
			variant = _Sprite_State_Static{},
		}
	case _Sprite_Metadata_Anim:
		s = Sprite_State {
			h       = sprite_h,
			variant = _Sprite_State_Anim{},
		}
	case _Sprite_Metadata_Tagged:
		s = Sprite_State {
			h = sprite_h,
			variant = _Sprite_State_Tagged{tag = t.? if t != nil else metadata.tags[0]},
		}
	}

	time.stopwatch_stop(&stopwatch)
	fmt.printfln("Took %s", time.stopwatch_duration(stopwatch))

	return
}

@(private = "file")
find_tag :: proc(tags: []Sprite_Tag, tag: Sprite_Tag) -> Maybe(int) {
	for p, i in tags {
		if p == tag {
			return i
		}
	}
	return nil // uh oh
}

draw_sprite :: proc(state: Sprite_State, pos: [2]f32, tint := rl.WHITE) {
	switch variant in state.variant {
	case _Sprite_State_Static:
		v := hm.get(&sprite_hm, state.h)
		image := hm.get(&image_hm, v.image)
		draw_texture(image.texture, pos, tint)
	case _Sprite_State_Anim:
		v := hm.get(&sprite_hm, state.h)
		image := hm.get(&image_hm, v.image)
		m := sprite_metadata[v.name]
		src := [2]f32{f32(variant.frame), 0} * m.frame_size
		draw_texture_rl_src(image.texture, {src.x, src.y, m.frame_size.x, m.frame_size.y}, pos, tint)
	case _Sprite_State_Tagged:
		v := hm.get(&sprite_hm, state.h)
		image := hm.get(&image_hm, v.image)
		m := sprite_metadata[v.name]
		tags := m.metadata.(_Sprite_Metadata_Tagged).tags
		if i_tag, ok := find_tag(tags, variant.tag).?; ok {
			src := [2]f32{f32(variant.frame), f32(i_tag)} * m.frame_size
			draw_texture_rl_src(image.texture, {src.x, src.y, m.frame_size.x, m.frame_size.y}, pos, tint)
		} else {
			panic("bad tag")
		}
	}
	// rl.DrawTextEx(font, fmt.ctprint(hm.get(&sprite_hm, state.h).name), pos, tile_size / 3, 0, rl.PINK) // debug
}

update_sprite :: proc(dt: f32, state: ^Sprite_State) -> bool {
	switch &variant in state.variant {
	case _Sprite_State_Static:
	case _Sprite_State_Anim:
		if !variant.frozen {
			v := hm.get(&sprite_hm, state.h)
			m := sprite_metadata[v.name].metadata.(_Sprite_Metadata_Anim)
			variant.t += dt
			if variant.t >= m.frame_t / 1000 {
				variant.t = 0
				variant.frame = (variant.frame + 1) %% m.num_frames
				return variant.frame == 0 // looped
			}
		}
	case _Sprite_State_Tagged:
		if !variant.frozen {
			v := hm.get(&sprite_hm, state.h)
			m := sprite_metadata[v.name].metadata.(_Sprite_Metadata_Tagged)
			variant.t += dt
			if variant.t >= m.frame_t / 1000 {
				variant.t = 0
				tag_idx := find_tag(m.tags, variant.tag).?
				variant.frame = (variant.frame + 1) %% m.num_frames[tag_idx]
				return variant.frame == 0 // looped
			}
		}
	}
	return false
}

freeze_sprite_frame :: proc(state: ^Sprite_State, frame: u16) {
	switch &variant in state.variant {
	case _Sprite_State_Static:
	case _Sprite_State_Anim:
		variant.frame = frame
		variant.frozen = true
	case _Sprite_State_Tagged:
		variant.frame = frame
		variant.frozen = true
	}
}

unfreeze_sprite :: proc(state: ^Sprite_State) {
	switch &variant in state.variant {
	case _Sprite_State_Static:
	case _Sprite_State_Anim:
		variant.frozen = false
	case _Sprite_State_Tagged:
		variant.frozen = false
	}
}

set_sprite_tag :: proc(state: ^Sprite_State, tag: Sprite_Tag) {
	switch &variant in state.variant {
	case _Sprite_State_Static:
	case _Sprite_State_Anim:
	case _Sprite_State_Tagged:
		variant.tag = tag
	// variant.frame = 0
	// variant.t = 0
	}
}

sprite_size_name :: proc(name: Sprite_Name) -> [2]f32 {
	return sprite_metadata[name].frame_size
}

sprite_size_state :: proc(state: Sprite_State) -> [2]f32 {
	v := hm.get(&sprite_hm, state.h)
	return sprite_metadata[v.name].frame_size
}

sprite_size :: proc {
	sprite_size_name,
	sprite_size_state,
}
