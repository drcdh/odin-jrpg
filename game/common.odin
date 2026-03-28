package game

import "core:fmt"

import la "core:math/linalg"

import rl "vendor:raylib"

Direction :: enum {
	None,
	North,
	NorthEast,
	East,
	SouthEast,
	South,
	SouthWest,
	West,
	NorthWest,
}

Direction_Vectors :: [Direction]Tile_Coord {
	.None      = {0, 0},
	.North     = {0, -1},
	.NorthEast = {+1, -1},
	.East      = {+1, 0},
	.SouthEast = {+1, +1},
	.South     = {0, +1},
	.SouthWest = {-1, +1},
	.West      = {-1, 0},
	.NorthWest = {-1, -1},
}

tile_to_pixel :: proc(t: Tile_Coord) -> Pixel_Coord {
	return Pixel_Coord {
		cast(Pixel)(t.x) * TILE_SIZE,
		cast(Pixel)(t.y) * TILE_SIZE,
	}
}

get_direction_input :: proc() -> Tile_Coord {
	input: Tile_Coord
	if rl.IsKeyDown(.UP) {
		input.y -= 1
	}
	if rl.IsKeyDown(.DOWN) {
		input.y += 1
	}
	if rl.IsKeyDown(.LEFT) {
		input.x -= 1
	}
	if rl.IsKeyDown(.RIGHT) {
		input.x += 1
	}
	return input
}

get_moves_toward :: proc(f, t, d: Tile_Coord) -> (Tile_Coord, Tile_Coord) {
	v := la.sign(d - t)
	if (v.x == 0 || v.y == 0) {
		return v, Tile_Coord{0, 0}
	}
	f := f
	if f.x == 0 && f.y == 0 {
		// projecting to {0, 0} causes a core dump :-(
		f.x = 1
	}
	move := la.projection(v, f)
	alt := v - move
	fmt.println(move, alt)
	return move, alt
}
