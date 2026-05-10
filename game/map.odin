package game

import hm "core:container/handle_map"
import rl "vendor:raylib"

Tileset_Id :: enum {
	Tileset_Terrain,
	Tileset_Town,
}

NUM_TILE_TYPES :: [2]int{
	16,
	36,
}

tileset_widths := [2]int {
	4,
	6,
}

TILESET_TERRAIN_PASSABLE := [NUM_TILE_TYPES[0]]bool {
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
TILESET_TOWN_PASSABLE := [NUM_TILE_TYPES[1]]bool {
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	true, // door
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
	false,
}

MAP_WIDTH :: 20
MAP_HEIGHT :: 20

Map_Layer :: [MAP_WIDTH][MAP_HEIGHT]int

Map :: []Map_Layer

level_tilesets : []Tileset_Id
p : [MAP_WIDTH][MAP_HEIGHT]bool
num_map_levels : int

load_map :: proc(next_map: Map, n: int) {
	m = next_map
	num_map_levels = n
	for i in 0 ..< MAP_WIDTH {
		for j in 0 ..< MAP_HEIGHT {
			p[j][i] = true
			for l in 0..<num_map_levels {
				m_ := m[l][j][i] - 1
				if m_ < 0 { continue}
				pl : bool
				switch l{
				case int(Tileset_Id.Tileset_Terrain):
					pl = TILESET_TERRAIN_PASSABLE[m_]
				case int(Tileset_Id.Tileset_Town):
					pl = TILESET_TOWN_PASSABLE[m_]
				}
				p[j][i] = p[j][i] && pl
			}
		}
	}
}

draw_map :: proc() {
	for i in 0 ..< MAP_WIDTH {
		for j in 0 ..< MAP_HEIGHT {
			for l in 0..<num_map_levels {
				draw_tile(int(level_tilesets[l]), m[l][j][i] - 1, tile_to_pixel(Tile_Coord{i, j}))
			}
		}
	}
}

draw_tile :: proc(ts_idx, t: int, pos: Pixel_Coord) {
	if t < 0 {return}
	x := t % tileset_widths[ts_idx]
	y := t / tileset_widths[ts_idx]
	source : Rect
	switch ts_idx {
	case 0:
		source = tileset_terrain[x][y]
	case 1:
		source = tileset_town[x][y]
	}
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
	return p[t.y][t.x]
}
