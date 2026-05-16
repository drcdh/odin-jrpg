package game

import hm "core:container/handle_map"
import "core:fmt"
import rl "vendor:raylib"

Kinematics :: struct {
	face:        Face,
	ghost:       bool,
	moving:      bool,
	offset:      Tile_Offset,
	offset_ease: Pixel,
	speed:       f32,
	tile:        Tile_Coord,
	z:           int,
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

Approach_Entity :: struct {
	id:        Id,
	countdown: f32,
	pause:     f32,
}

Control :: struct {}

Pacing :: struct {
	countdown: f32,
	pause:     f32,
	route:     int,
	step:      int,
}

State :: union {
	Approach_Entity,
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
	talk:     []Event,
	trap:     []Event,
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

set_destination :: proc(e: ^Entity, d: Tile_Coord) {
	e.tile += d
	e.offset = -tile_to_pixel(d)
	e.offset_ease = 1
	e.moving = true
	// fmt.printfln("% 4d: Set destination of entity %s by %w to %w", frame_count, e.n, d, e.tile)
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

try_set_adjacent_destination :: proc(e: ^Entity, d: Tile_Coord) -> bool {
	if tile_free(e.tile + d) {
		set_destination(e, d)
		return true
	}
	return false
}

try_set_destination :: proc(e: ^Entity, d: Tile_Coord) {
	move, alt := get_moves_toward(e^, d)
	e.face = get_face_toward(move)
	if !try_set_adjacent_destination(e, move) {
		_ = try_set_adjacent_destination(e, alt)
	}
}

try_set_destination_toward :: proc(e: ^Entity, t: Kinematics) {
	move, alt := get_moves_toward(e^, t.tile)
	e.face = get_face_toward(move)
	if !try_set_adjacent_destination(e, move) {
		_ = try_set_adjacent_destination(e, alt)
	}
}

update_entity :: proc(dt: f32, e: ^Entity) {
	#partial switch &v in e.v {
	case Animation:
		animation_update(&v, dt)
	case Facing_Animation:
		facing_animation_update(&v, e.k.face, dt)
	}
	if update_kinematics(dt, &e.k) {
		// first frame completely on this tile
		if trap, ok := get_entity_at_tile(e.tile, e.id).?; ok {
			fmt.printfln("% 4d: %s stepped onto %w", frame_count, e.n, trap)
			activate_entity_trap_script(trap)
		}
		if tile_outside(e.tile) {
			fmt.printfln("% 4d: %s leaving level", frame_count, e.n)
			set_entity_busy(e.id, true) // hack
			next_level = .LEVEL_OVERWORLD
			start_script(CHANGE_LEVEL[:])
		}
	}
	if !e.busy && !e.disabled && !e.k.moving {
		switch &s in e.state {
		case Approach_Entity:
			s.countdown -= dt
			if s.countdown <= 0 {
				if th, ok := get_entity(s.id).?; ok {
					t := hm.get(&entities, th)
					try_set_destination_toward(e, t)
				}
				s.countdown = s.pause
			}
		case Control:
			player_control(dt, e)
		case Pacing:
			destinations := level_routes[s.route]
			s.countdown -= dt
			if s.countdown <= 0 {
				if entity_at_tile(e^, destinations[s.step]) {
					s.step += 1
					if s.step >= len(destinations) {s.step = 0}
				}
				// fmt.println("step", s.step, "dest", destinations[s.step], "pos", e.tile)
				try_set_destination(e, destinations[s.step])
				s.countdown = s.pause
			}
		}
	}
}

update_kinematics :: proc(dt: f32, k: ^Kinematics) -> bool {
	if k.moving {
		k.offset_ease -= dt * k.speed
		if k.offset_ease < 0 {
			k.offset_ease = 0
			k.moving = false
			return true
		}
	}
	if level_map_wrap {
		k.tile.x %%= map_dim.x
		k.tile.y %%= map_dim.y
	}
	return false
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
		try_set_destination(p, p.k.tile + input)
	} else {
		if get_input(.ENTER) {
			if entity_in_front, ok := get_entity_at_tile(tile_in_front(p)).?; ok {
				activate_entity_talk_script(entity_in_front)
			}
			if boat_mode {
				t := tile_in_front(p)
				p := LEVEL_OVERWORLD_PASSABLE[t.y][t.x]
				if p & PARTY_IMPASSABLE  == 0{
					start_script(LEAVE_BOAT[:])
				}
			}
		}
	}
}
