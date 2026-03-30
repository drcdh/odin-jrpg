package game

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

Visual_Solid_Rect :: struct {
	size:  Pixel_Dim,
	color: rl.Color,
}

Visual :: union {
	Visual_Solid_Rect,
	Text_Display,
}

draw_solid_rect :: proc(k: Kinematics, v: Visual_Solid_Rect) {
	rl.DrawRectangleV(tile_to_pixel(k.tile) + k.offset * k.offset_ease, v.size, v.color)
}

draw_entity :: proc(e: Entity) {
	if !e.disabled {
		switch v in e.v {
		case Visual_Solid_Rect:
			draw_solid_rect(e.k, v)
		case Text_Display:
			draw_text_display(v)
		}
	}
}

set_destination :: proc(k: ^Kinematics, d: Tile_Coord) {
	k.tile += d
	k.offset = -tile_to_pixel(d)
	k.offset_ease = 1
	k.moving = true
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
	busy:     bool, // script will not run if true
	disabled: bool, // script will not run and will not be displayed if true
	id:       Id,
	k:        Kinematics,
	n:        Name,
	s:        Script,
	state:    State,
	v:        Visual,
}

update_entity :: proc(dt: f32, e: ^Entity) {
	update_kinematics(dt, &e.k)
	if !e.busy && !e.disabled {
		e.s(dt, e)
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
