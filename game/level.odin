package game

import rl "vendor:raylib"

DUDE_COLOR :: rl.Color{80, 80, 90, 255}
PLAYER_COLOR :: rl.Color{200, 120, 120, 255}

DUDE_DESTINATIONS :: [4]Tile_Coord{{18, 10}, {18, 8}, {16, 8}, {16, 10}}
DUDE_PAUSE: f32 : 1

dude_step := 0
dude_countdown: f32

dude_pace :: proc(dt: f32, dude: ^Entity) {
	dd := DUDE_DESTINATIONS
	if !dude.k.moving {
		dude_countdown -= dt
		if dude_countdown <= 0 {
			if entity_at_tile(dude^, dd[dude_step]) {
				dude_step += 1
				if dude_step >= 4 {dude_step = 0}
			}
			try_set_destination(&dude.k, dd[dude_step])
			dude_countdown = DUDE_PAUSE
		}
	}
}

start_level :: proc() {
	m = build_map()

	player := Entity {
		k = Kinematics {
			face = Direction_Vectors[.South],
			tile = Tile_Coord{15, 15},
			speed = 3,
		},
		n = "Player",
		s = player_control,
		v = Visual{color = PLAYER_COLOR, size = TILE_DIM},
	}

	dude := Entity {
		k = Kinematics{tile = Tile_Coord{18, 10}, speed = 2},
		n = "Dude",
		s = dude_pace,
		v = Visual{color = DUDE_COLOR, size = TILE_DIM},
	}

	append(&entities, player)
	append(&entities, dude)
}
