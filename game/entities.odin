package game

import "core:fmt"

Kinematics :: struct {
	face:        Sprite_Tag,
	ghost:       bool,
	moving:      bool,
	offset:      Tile_Offset,
	offset_ease: Pixel,
	speed:       f32,
	tile:        Tile_Coord,
	z:           int,
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

Entity_Script :: proc(_: Id)

Entity_State :: union {
	Approach_Entity,
	Control,
	Pacing,
}

Entity :: struct {
	using k:  Kinematics,
	busy:     bool, // script will not run if true
	disabled: bool, // script will not run and will not be displayed if true
	handle:   Entity_Handle,
	id:       Id,
	light:    f16,
	n:        Name,
	talk:     Entity_Script,
	trap:     Entity_Script,
	state:    Entity_State,
	v:        Sprite_State,
}

draw_entity :: proc(e: ^Entity) {
	draw_sprite(e.v, entity_coord(e))
	// rl.DrawTextEx(font, fmt.ctprint(e.id), entity_coord(e), tile_size / 4, 0, rl.BLACK) // debug
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

get_face_toward :: proc(d: Tile_Coord) -> Sprite_Tag {
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
	if e.ghost || tile_free(e.tile + d) {
		set_destination(e, d)
		return true
	}
	return false
}

try_set_destination :: proc(e: ^Entity, d: Tile_Coord) -> bool {
	move, alt := get_moves_toward(e^, d)
	e.face = get_face_toward(move)
	set_sprite_tag(&e.v, e.face)
	return try_set_adjacent_destination(e, move) || try_set_adjacent_destination(e, alt)
}

try_set_destination_toward :: proc(e: ^Entity, t: Kinematics) -> bool {
	move, alt := get_moves_toward(e^, t.tile)
	e.face = get_face_toward(move)
	set_sprite_tag(&e.v, e.face)
	return try_set_adjacent_destination(e, move) || try_set_adjacent_destination(e, alt)
}

update_entity :: proc(dt: f32, e: ^Entity) {
	update_sprite(dt, &e.v)

	if update_kinematics(dt, &e.k) {
		// first frame completely on this tile
		if trap := get_world_entity_at_tile(e.tile, e.id); trap != nil && trap.trap != nil {
			fmt.printfln("% 4d: %s stepped onto %s", frame_count, e.n, trap.n)
			entity_trap(trap^)
		}
		if e.trap != nil {
			if catch := get_world_entity_at_tile(e.tile, e.id); catch != nil {
				fmt.printfln("% 4d: %s caught %s", frame_count, e.n, catch.n)
				entity_trap(e^)
			}
		}
		if tile_outside(e.tile) {
			fmt.printfln("% 4d: %s leaving level", frame_count, e.n)
			set_world_entity_busy(e.id, true) // hack
			change_level(.Level_Overworld)
		}
		if e.id == PLAYER_ID {
			try_random_encounter(current_level, e.tile)
		}
	}

	if !e.busy && !e.disabled && !e.k.moving {
		switch &s in e.state {
		case Approach_Entity:
			s.countdown -= dt
			if s.countdown <= 0 {
				target_entity := get_world_entity(s.id)
				try_set_destination_toward(e, target_entity)
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
				_ = try_set_destination(e, destinations[s.step])
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

entity_at_tile :: proc(k: Kinematics, t: Tile_Coord) -> bool {
	return k.tile == t
}

entity_at_z :: proc(k: Kinematics, z: int) -> bool {
	return (z == 0 && k.z <= 0) || (z == k.z) || (z == Z_MAX && k.z >= Z_MAX)
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
			set_sprite_tag(&p.v, .Down)
		} else if input.y < 0 {
			set_sprite_tag(&p.v, .Up)
			p.k.face = .Up
		} else if input.x > 0 {
			set_sprite_tag(&p.v, .Right)
			p.k.face = .Right
		} else if input.x < 0 {
			set_sprite_tag(&p.v, .Left)
		}
		if try_set_destination(p, p.k.tile + input) {
			do_party_step_effects()
		}
	} else {
		if get_input(.ENTER) {
			if entity_in_front := get_world_entity_at_tile(tile_in_front(p), nil);
			   entity_in_front != nil && entity_in_front.talk != nil {
				entity_talk(entity_in_front^)
			}
			if boat_mode {
				t := tile_in_front(p)
				p := LEVEL_OVERWORLD_PASSABLE[t.y][t.x]
				if p & PARTY_IMPASSABLE == 0 {
					leave_boat(BOAT_ID)
				}
			}
		}
	}
}

entity_talk :: proc(e: Entity) {
	e.talk(e.id)
}

entity_trap :: proc(e: Entity) {
	e.trap(e.id)
}
