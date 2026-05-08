package game

import hm "core:container/handle_map"
import "core:math/rand"
import rl "vendor:raylib"

NUM_TILE_TYPES :: 16

TILESET_WIDTH :: 4

PASSABLE :: [NUM_TILE_TYPES]bool {
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	true,
	false,
	false,
	false,
	false,
}

MAP_WIDTH :: 30
MAP_HEIGHT :: 30

Map_Layer :: distinct [MAP_WIDTH][MAP_HEIGHT]int

Map :: distinct Map_Layer

build_map :: proc() -> Map {
	m: Map

	for i in 1 ..= MAP_WIDTH - 2 {
		for j in 1 ..= MAP_HEIGHT - 2 {
			m[i][j] = 4
			if abs(MAP_WIDTH / 2 - i) > 8 || abs(MAP_HEIGHT / 2 - j) > 8 {
				m[i][j] = rand.int_max(NUM_TILE_TYPES)
			}
		}
	}

	return m
}

draw_map :: proc(m: Map) {
	for i in 0 ..< MAP_WIDTH {
		for j in 0 ..< MAP_HEIGHT {
			draw_tile(m[i][j], tile_to_pixel(Tile_Coord{i, j}))
		}
	}
}

draw_tile :: proc(t: int, pos: Pixel_Coord) {
	x := t % TILESET_WIDTH
	y := t / TILESET_WIDTH
	source := tileset_terrain[x][y]
	dest := Rect{pos.x, pos.y, tile_size, tile_size}
	origin: Pixel_Coord
	rotation: f32

	rl.DrawTexturePro(atlas, source, dest, origin, rotation, rl.WHITE)
}

valid_tile_coord :: proc(t: Tile_Coord) -> bool {
	return !(t.x < 0 || t.y < 0 || t.x >= MAP_WIDTH || t.y >= MAP_HEIGHT)
}

tile_free :: proc(t: Tile_Coord) -> bool {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.tile == t && !e.ghost {
			return false
		}
	}
	p := PASSABLE
	return p[m[t.x][t.y]]
}
