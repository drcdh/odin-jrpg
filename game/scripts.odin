package game

import rl "vendor:raylib"

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

player_control :: proc(_: f32, p: ^Entity) {
	if !p.k.moving {
		input := get_direction_input()
		if (input.x != 0 || input.y != 0) {
			try_set_destination(&p.k, p.k.tile + input)
		}
	}
}
