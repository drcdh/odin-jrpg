package game

import hm "core:container/handle_map"
import rl "vendor:raylib"

Tileset_Id :: enum {
	Tileset_Terrain,
	Tileset_Town,
}

tileset_widths := [2]int {
	4,
	6,
}

map_dim : [2]Tile_T
map_rt : rl.RenderTexture

draw_map :: proc() {
	rl.DrawTexturePro(map_rt.texture, {0, 0, f32(map_rt.texture.width), -f32(map_rt.texture.height)}, {0, 0, f32(map_rt.texture.width), -f32(map_rt.texture.height)}, {}, 0, rl.WHITE)
}

unload_map :: proc() {
	rl.UnloadRenderTexture(map_rt)
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
	return !(t.x < 0 || t.y < 0 || t.x >= map_dim.x || t.y >= map_dim.y)
}

tile_free :: proc(t: Tile_Coord) -> (free : bool) {
	switch current_level {
	case .LEVEL_0:
		free = LEVEL_0_PASSABLE[t.y][t.x]
	case .LEVEL_1:
		free = LEVEL_1_PASSABLE[t.y][t.x]
	case .LEVEL_2:
		free = LEVEL_2_PASSABLE[t.y][t.x]
	}
	if !free { return }

	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.tile == t && !e.ghost {
			free = false
			break
		}
	}
	return
}
