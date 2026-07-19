package game

import la "core:math/linalg"
import rl "vendor:raylib"

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

tile_to_pixel_Tile_Coord :: proc(t: Tile_Coord) -> Pixel_Coord {
	return {cast(Pixel)(t.x) * tile_size, cast(Pixel)(t.y) * tile_size}
}

tile_to_pixel_int_int :: proc(i, j: int) -> Pixel_Coord {
	return {f32(i) * tile_size, f32(j) * tile_size}
}

tile_to_pixel_f32_int :: proc(i: f32, j: int) -> Pixel_Coord {
	return {i * tile_size, f32(j) * tile_size}
}

tile_to_pixel_int_f32 :: proc(i: int, j: f32) -> Pixel_Coord {
	return {f32(i) * tile_size, j * tile_size}
}

tile_to_pixel_f32_f32 :: proc(i, j: f32) -> Pixel_Coord {
	return {i * tile_size, j * tile_size}
}

tile_to_pixel :: proc {
	tile_to_pixel_Tile_Coord,
	tile_to_pixel_int_int,
	tile_to_pixel_f32_int,
	tile_to_pixel_int_f32,
	tile_to_pixel_f32_f32,
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

shift_windowed_selection :: proc(d, s, w, W, N: int) -> (int, int) {
	s, w := s, w
	s += d
	if s < 0 {
		s = N - 1
		w = max(0, N - W)
	} else if s >= N {
		s = 0
		w = 0
	} else if s >= w + W {
		w = s - W + 1
	} else if s < w {
		w = s
	}
	return s, w
}

grid_change :: proc(i, dx, dy, W, H: int) -> int {
	// if dx or dy are non-zero, their magnitude is assumed to be 1
	_i := i
	if dx < 0 {
		if i % W == 0 {
			// left edge
			_i += W - 1
		} else {
			_i -= 1
		}
	} else if dx > 0 {
		if (i + 1) % W == 0 {
			// right edge
			_i -= W - 1
		} else {
			_i += 1
		}
	}
	if dy < 0 {
		if i < W {
			// top edge
			_i += W * (H - 1)
		} else {
			_i -= W
		}
	} else if dy > 0 {
		if i >= W * (H - 1) {
			// bottom edge
			_i -= W * (H - 1)
		} else {
			_i += W
		}
	}
	return _i
}

remove_margins :: proc(r: rl.Rectangle, p: f32) -> rl.Rectangle {
	return {x = r.x + p, y = r.y + p, width = r.width - 2 * p, height = r.height - 2 * p}
}
