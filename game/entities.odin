package game

import hm "core:container/handle_map"
import rl "vendor:raylib"

Kinematics :: struct {
	face:        Face,
	ghost:       bool,
	moving:      bool,
	offset:      Tile_Offset,
	offset_ease: Pixel,
	speed:       f32,
	tile:        Tile_Coord,
}

Visual_Solid_Circle :: struct {
	radius: Pixel,
	color:  rl.Color,
}

Visual_Solid_Rect :: struct {
	size:  Pixel_Dim,
	color: rl.Color,
}

Visual_Facing_Animation :: struct {
	left, right, up, down: Animation_Name,
}

Visual :: union {
	Animation,
	Facing_Animation,
	Texture_Name,
	Visual_Solid_Circle,
	Visual_Solid_Rect,
}

Name :: cstring

Control :: struct {}

Pacing :: struct {
	countdown: f32,
	pause:     f32,
	route:     int,
	step:      int,
}

State :: union {
	Control,
	Pacing,
}

Entity_Handle :: distinct hm.Handle16

Entity :: struct {
	using k:  Kinematics,
	busy:     bool, // script will not run if true
	disabled: bool, // script will not run and will not be displayed if true
	handle:   Entity_Handle,
	id:       Id,
	n:        Name,
	script:   []Event,
	state:    State,
	v:        Visual,
}

draw_solid_rect :: proc(k: Kinematics, v: Visual_Solid_Rect) {
	rl.DrawRectangleV(tile_to_pixel(k.tile) + k.offset * k.offset_ease, v.size, v.color)
}

draw_solid_circle :: proc(k: Kinematics, v: Visual_Solid_Circle) {
	rl.DrawCircleV(tile_dim / 2 + tile_to_pixel(k.tile) + k.offset * k.offset_ease, v.radius, v.color)
}

draw_entity :: proc(e: ^Entity) {
	switch v in e.v {
	case Visual_Solid_Circle:
		draw_solid_circle(e, v)
	case Visual_Solid_Rect:
		draw_solid_rect(e, v)
	case Animation:
		draw_animation(v, entity_coord(e), rl.WHITE)
	case Facing_Animation:
		draw_facing_animation(v, entity_coord(e), rl.WHITE)
	case Texture_Name:
		draw_texture(v, entity_coord(e), rl.WHITE)
	}
}

entity_coord :: proc(k: Kinematics) -> Pixel_Coord {
	return tile_to_pixel(k.tile) + k.offset * k.offset_ease
}

set_destination :: proc(k: ^Kinematics, d: Tile_Coord) {
	k.tile += d
	k.offset = -tile_to_pixel(d)
	k.offset_ease = 1
	k.moving = true
}

get_face_toward :: proc(d: Tile_Coord) -> Face {
	switch d {
	case {1, 0}:
		return .Right
	case {-1, 0}:
		return .Left
	case {0, 1}:
		return .Down
	case {0, -1}:
		return .Up
	}
	return nil
}

try_set_adjacent_destination :: proc(k: ^Kinematics, d: Tile_Coord) -> bool {
	k.face = get_face_toward(d)
	if tile_free(k.tile + d) {
		set_destination(k, d)
		return true
	}
	return false
}

try_set_destination :: proc(k: ^Kinematics, d: Tile_Coord) {
	move, alt := get_moves_toward(k^, d)
	if !try_set_adjacent_destination(k, move) {
		_ = try_set_adjacent_destination(k, alt)
	}
}

update_entity :: proc(dt: f32, e: ^Entity) {
	update_kinematics(dt, &e.k)
	#partial switch &v in e.v {
	case Animation:
		animation_update(&v, dt)
	case Facing_Animation:
		facing_animation_update(&v, e.k.face, dt)
	}
	if !e.busy && !e.disabled && !e.k.moving {
		switch &s in e.state {
		case Pacing:
			destinations := LEVEL_ROUTES[s.route]
			s.countdown -= dt
			if s.countdown <= 0 {
				if entity_at_tile(e^, destinations[s.step]) {
					s.step += 1
					if s.step >= len(destinations) {s.step = 0}
				}
				try_set_destination(&e.k, destinations[s.step])
				s.countdown = s.pause
			}
		case Control:
			player_control(dt, e)
		}
	}
}

update_kinematics :: proc(dt: f32, k: ^Kinematics) {
	if k.moving {
		k.offset_ease -= dt * k.speed
		if k.offset_ease < 0 {
			k.offset_ease = 0
			k.moving = false
		}
	}
}

entity_at_tile :: proc(e: Entity, t: Tile_Coord) -> bool {
	return e.k.tile == t
}

tile_in_front :: proc(e: ^Entity) -> Tile_Coord {
	return get_adjacent_tile(e.tile, e.face)
}

get_entity_pixel :: proc(e: Entity) -> Pixel_Coord {
	return tile_to_pixel(e.k.tile) + e.k.offset * e.k.offset_ease
}

player_control :: proc(_: f32, p: ^Entity) {
	input := get_direction_input()
	if (input.x != 0 || input.y != 0) {
		if input.y > 0 {
			p.k.face = .Down
		} else if input.y < 0 {
			p.k.face = .Up
		} else if input.x > 0 {
			p.k.face = .Right
		} else if input.x < 0 {
			p.k.face = .Left
		}
		try_set_destination(&p.k, p.k.tile + input)
	} else {
		if get_input(.ENTER) {
			if entity_in_front, ok := get_entity_at_tile(tile_in_front(p)).?; ok {
				activate_entity(entity_in_front)
			}
		}
	}
}
