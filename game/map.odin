package game

import hm "core:container/handle_map"
import rl "vendor:raylib"

Tileset_Id :: enum {
	Tileset_Terrain,
	Tileset_Town,
	Tileset_Overworld,
}

tileset_widths := [Tileset_Id]int {
	.Tileset_Terrain   = 4,
	.Tileset_Town      = 6,
	.Tileset_Overworld = 9,
}

map_dim: [2]Tile_T
map_rt: rl.RenderTexture

draw_map :: proc() {
	w := f32(map_rt.texture.width)
	h := f32(map_rt.texture.height)
	rl.DrawTexturePro(
		map_rt.texture,
		{0, 0, w, -h},
		{0, 0, w, -h},
		{},
		0,
		rl.WHITE,
	)
	if level_map_wrap {
		rl.DrawTexturePro(
			map_rt.texture,
			{0, 0, w, -h},
			{0, -h, w, -h},
			{},
			0,
			rl.WHITE,
		)
		rl.DrawTexturePro(
			map_rt.texture,
			{0, 0, w, -h},
			{0, h, w, -h},
			{},
			0,
			rl.WHITE,
		)
		rl.DrawTexturePro(
			map_rt.texture,
			{0, 0, w, -h},
			{-w, 0, w, -h},
			{},
			0,
			rl.WHITE,
		)
		rl.DrawTexturePro(
			map_rt.texture,
			{0, 0, w, -h},
			{w, 0, w, -h},
			{},
			0,
			rl.WHITE,
		)
	}
}

unload_map :: proc() {
	rl.UnloadRenderTexture(map_rt)
}

draw_tile :: proc(ts: Tileset_Id, t: int, pos: Pixel_Coord) {
	if t < 0 {return}
	x := t % tileset_widths[ts]
	y := t / tileset_widths[ts]
	source: Rect
	switch ts {
	case .Tileset_Terrain:
		source = tileset_terrain[x][y]
	case .Tileset_Town:
		source = tileset_town[x][y]
	case .Tileset_Overworld:
		source = tileset_overworld[x][y]
	}
	dest := Rect{pos.x, pos.y, tile_size, tile_size}
	origin: Pixel_Coord
	rotation: f32

	rl.DrawTexturePro(atlas, source, dest, origin, rotation, rl.WHITE)
}

draw_tile_tmx :: proc(l, t: int, pos: Pixel_Coord) {
	ts, t_ := tmx_ts_tile(l, t)
	draw_tile(ts, t_, pos)
}

tmx_ts_tile :: proc(l, t: int) -> (Tileset_Id, int) {
	if t <= 0 {return Tileset_Id(0), -1}
	ts := 0
	t := t
	for ts + 1 < len(level_firstgids) && t >= level_firstgids[ts + 1] {
		ts += 1
		t -= level_firstgids[ts] - 1
	}
	t -= 1
	return level_tilesets[ts], t
}

valid_tile_coord :: proc(t: Tile_Coord) -> bool {
	return !(t.x < 0 || t.y < 0 || t.x >= map_dim.x || t.y >= map_dim.y)
}

tile_free :: proc(t: Tile_Coord) -> (free: bool) {
	t := t
	if level_map_wrap {
		t.x %%= map_dim.x
		t.y %%= map_dim.y
	} else if tile_outside(t) {
		free = true
		return
	}
	switch current_level {
	case .LEVEL_0:
		free = LEVEL_0_PASSABLE[t.y][t.x]
	case .LEVEL_1:
		free = LEVEL_1_PASSABLE[t.y][t.x]
	case .LEVEL_2:
		free = LEVEL_2_PASSABLE[t.y][t.x]
	case .LEVEL_OVERWORLD:
		free = LEVEL_OVERWORLD_PASSABLE[t.y][t.x]
	}
	if !free {return}

	it := hm.iterator_make(&entities)
	for e, _ in hm.iterate(&it) {
		if e.tile == t && !e.ghost {
			free = false
			break
		}
	}
	return
}

tile_outside :: proc(t: Tile_Coord) -> bool {
	return t.x < 0 || t.x >= map_dim.x || t.y < 0 || t.y >= map_dim.y
}
