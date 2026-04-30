package game

import hm "core:container/handle_map"
import "core:math/rand"
import rl "vendor:raylib"

NUM_TILE_TYPES :: 3

TILE_COLORS :: [NUM_TILE_TYPES]rl.Color{rl.BLACK, rl.GREEN, rl.GRAY}

TILE_INDICES :: [NUM_TILE_TYPES]int{0, 1, 2}

PASSABLE :: [NUM_TILE_TYPES]bool{false, true, false}

MAP_WIDTH :: 30
MAP_HEIGHT :: 30

Map_Layer :: distinct [MAP_WIDTH][MAP_HEIGHT]int

Map :: distinct Map_Layer

build_map :: proc() -> Map {
	m: Map

	for i in 1 ..= MAP_WIDTH - 2 {
		for j in 1 ..= MAP_HEIGHT - 2 {
			m[i][j] = 1
			if abs(MAP_WIDTH / 2 - i) > 8 || abs(MAP_HEIGHT / 2 - j) > 8 {
				m[i][j] = rand.int_max(NUM_TILE_TYPES)
			}
		}
	}

	return m
}

draw_map :: proc(m: Map) {
	colors := TILE_COLORS
	for i in 0 ..< MAP_WIDTH {
		for j in 0 ..< MAP_HEIGHT {
			rl.DrawRectangleV(tile_to_pixel(Tile_Coord{i, j}), TILE_DIM, colors[m[i][j]])
		}
	}
}

valid_tile_coord :: proc(t: Tile_Coord) -> bool {
	return !(t.x < 0 || t.y < 0 || t.x >= MAP_WIDTH || t.y >= MAP_HEIGHT)
}

tile_free :: proc(t: Tile_Coord) -> bool {
	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.k.tile == t && !e.k.ghost {
			return false
		}
	}
	p := PASSABLE
	return p[m[t.x][t.y]]
}
