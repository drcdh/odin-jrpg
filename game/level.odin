package game

import rl "vendor:raylib"

PLAYER_ID: Id = 0
DUDE_ID: Id = 1

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
		busy = true, // for welcome text
		id = PLAYER_ID,
		k = Kinematics {
			face = Direction_Vectors[.South],
			tile = Tile_Coord{15, 15},
			speed = 3,
		},
		n = "Player",
		s = player_control,
		v = Visual_Solid_Rect{color = PLAYER_COLOR, size = TILE_DIM},
	}

	dude := Entity {
		k = Kinematics{tile = Tile_Coord{18, 10}, speed = 2},
		id = DUDE_ID,
		n = "Dude",
		s = dude_pace,
		v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
	}

	append(&entities, player)
	append(&entities, dude)

	append(&text, Text_Display {
		id = 12,
		text = "Oh, hey! What's up, {player}?\n(Press spacebar to start)",
		on_end = proc(_: int) {
			set_entity_busy(PLAYER_ID, false)
		},
		pause = 2,
		wait = true,
	})
}
