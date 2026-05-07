package game

import la "core:math/linalg"

Id :: int

NULL_ID :: 9999

Pixel :: f32
Pixel_Coord :: [2]Pixel
Pixel_Dim :: [2]Pixel

Tile_T :: int
Tile_Coord :: [2]Tile_T
Tile_Offset :: Pixel_Coord

TILE_SIZE :: 16
tile_size: Pixel
tile_dim: Pixel_Dim

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

Face :: enum {
	Left,
	Right,
	Up,
	Down,
}

face_tile_coord :: proc(f: Face) -> Tile_Coord {
	t: Tile_Coord
	switch f {
	case .Left:
		t = {-1, 0}
	case .Right:
		t = {1, 0}
	case .Up:
		t = {0, -1}
	case .Down:
		t = {0, 1}
	}
	return t
}

get_adjacent_tile :: proc(t: Tile_Coord, f: Face) -> Tile_Coord {
	return t + face_tile_coord(f)
}

tile_to_pixel :: proc(t: Tile_Coord) -> Pixel_Coord {
	return Pixel_Coord{cast(Pixel)(t.x) * tile_size, cast(Pixel)(t.y) * tile_size}
}

get_moves_toward :: proc(k: Kinematics, d: Tile_Coord) -> (Tile_Coord, Tile_Coord) {
	v := la.sign(d - k.tile)
	if (v.x == 0 || v.y == 0) {
		return v, Tile_Coord{0, 0}
	}
	f := face_tile_coord(k.face)
	move := la.projection(v, f)
	alt := v - move
	return move, alt
}
