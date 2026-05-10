package game

import hm "core:container/handle_map"
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

MAP_WIDTH :: 20
MAP_HEIGHT :: 20

Map_Layer :: distinct [MAP_WIDTH][MAP_HEIGHT]int

Map :: distinct Map_Layer

draw_map :: proc(m: Map) {
	for i in 0 ..< MAP_WIDTH {
		for j in 0 ..< MAP_HEIGHT {
			draw_tile(m[j][i] - 1, tile_to_pixel(Tile_Coord{i, j}))
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
	return p[m[t.y][t.x] - 1]
}
