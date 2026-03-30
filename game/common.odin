package game

import la "core:math/linalg"

import rl "vendor:raylib"

Id :: int

Pixel :: f32
Pixel_Coord :: [2]Pixel
Pixel_Dim :: [2]Pixel

PIXEL_ORIGIN: Pixel_Coord

Tile_T :: int
Tile_Coord :: [2]Tile_T
Tile_Offset :: Pixel_Coord

TILE_SIZE: Pixel : 32
TILE_DIM :: Pixel_Dim{TILE_SIZE, TILE_SIZE}

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
	return Pixel_Coord{cast(Pixel)(t.x) * TILE_SIZE, cast(Pixel)(t.y) * TILE_SIZE}
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
	return move, alt
}
