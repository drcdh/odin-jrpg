package game

import "core:fmt"

import rl "vendor:raylib"

Kinematics :: struct {
	face:        Tile_Coord,
	ghost:       bool,
	moving:      bool,
	offset:      Tile_Offset,
	offset_ease: Pixel,
	speed:       f32,
	tile:        Tile_Coord,
}

Visual :: struct {
	size:  Pixel_Dim,
	color: rl.Color,
}

draw_entity :: proc(e: Entity) {
	_draw_entity(e.k, e.v)
}

_draw_entity :: proc(k: Kinematics, v: Visual) {
	rl.DrawRectangleV(
		tile_to_pixel(k.tile) + k.offset * k.offset_ease,
		v.size,
		v.color,
	)
}

Player_Control :: struct {
	prev_input: Tile_Coord,
}

set_destination :: proc(k: ^Kinematics, d: Tile_Coord) {
	k.tile += d
	k.offset = -tile_to_pixel(d)
	k.offset_ease = 1
	k.moving = true
	// fmt.println(k)
}

try_set_adjacent_destination :: proc(k: ^Kinematics, d: Tile_Coord) -> bool {
	k.face = d
	if tile_free(k.tile + d) {
		set_destination(k, d)
		return true
	}
	return false
}

try_set_destination :: proc(k: ^Kinematics, d: Tile_Coord) {
	move, alt := get_moves_toward(k.face, k.tile, d)
	if !try_set_adjacent_destination(k, move) {
		_ = try_set_adjacent_destination(k, alt)
	}
}

Name :: string
Script :: proc(_: f32, _: ^Entity)

Entity :: struct {
	k: Kinematics,
	n: Name,
	s: Script,
	v: Visual,
}

update_entity :: proc(dt: f32, e: ^Entity) {
	// fmt.println("updating entity", e.n)
	update_kinematics(dt, &e.k)
	update_control(dt, e)
}

update_kinematics :: proc(dt: f32, k: ^Kinematics) {
	if k.moving {
		// fmt.println("moving")
		k.offset_ease -= dt * k.speed
		if k.offset_ease < 0 {
			k.offset_ease = 0
			k.moving = false
		}
	}
}

update_control :: proc(dt: f32, entity: ^Entity) {
	if !entity.k.moving {
		// fmt.println("not moving")
		entity.s(dt, entity)
		// switch &c in entity.c {
		// case Player_Control:
		// 	{
		// 		control_player(&entity.k)
		// 	}
		// case Script_Control:
		// 	{
		// 		c.f(dt, entity, c.data)
		// 	}
		// }
	}
}

entity_at_tile :: proc(e: Entity, t: Tile_Coord) -> bool {
	return e.k.tile == t
}
