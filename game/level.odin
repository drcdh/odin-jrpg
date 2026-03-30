package game

import "core:fmt"
import rl "vendor:raylib"

PLAYER_ID: Id = 0
DUDE_ID: Id = 1

DUDE_COLOR :: rl.Color{80, 80, 90, 255}
PLAYER_COLOR :: rl.Color{200, 120, 120, 255}

DUDE_SPAWN :: Tile_Coord{15, 15}
DUDE_NUM_DEST_1 :: 4
DUDE_DESTINATIONS_1 :: [DUDE_NUM_DEST_1]Tile_Coord{{18, 10}, {18, 8}, {16, 8}, {16, 10}}
DUDE_PAUSE_1: f32 : 1

DUDE_WALK :: Tile_Coord{10, 10}

DUDE_NUM_DEST_2 :: 2
DUDE_DESTINATIONS_2 :: [DUDE_NUM_DEST_2]Tile_Coord{{10, 10}, {10, 14}}
DUDE_PAUSE_2: f32 : 0

Control :: struct {}

Pacing :: struct {
	countdown: f32,
	route:     int,
	step:      int,
}

Talking :: struct {
	line: int,
	tree: int,
}

State :: union {
	Control,
	Pacing,
	Talking,
}

DUDE_TEXT_1 :: [2]Text_Display {
	{id = 100, text = "Oh, hey! What's up, {player}?", on_end = proc(_: int) {
			set_entity_dialogue(DUDE_ID, 1)
		}, wait = true},
	{
		id = 101,
		text = "Anyway, I'm going over there now.",
		on_end = proc(_: int) {
			set_entity_state(DUDE_ID, Pacing{route = 2})
			set_entity_busy(DUDE_ID, false)
			// set_entity_busy(PLAYER_ID, false)
		},
		wait = true,
	},
}
DUDE_TEXT_2 :: [1]Text_Display{{id = 102, text = "Keep on keepin' on.", pause = 2, wait = false}}

// pace :: proc(e: ^Entity, n: int, dest: []Tile_Coord, pause: f32){}

dude_script :: proc(dt: f32, dude: ^Entity) {
	#partial switch &s in dude.state {
	case Pacing:
		if s.route == 1 {
			dd := DUDE_DESTINATIONS_1
			if !dude.k.moving {
				s.countdown -= dt
				if s.countdown <= 0 {
					if entity_at_tile(dude^, dd[s.step]) {
						s.step += 1
						if s.step >= DUDE_NUM_DEST_1 {s.step = 0}
					}
					try_set_destination(&dude.k, dd[s.step])
					s.countdown = DUDE_PAUSE_1
				}
			}
		} else if s.route == 2 {
			dd := DUDE_DESTINATIONS_2
			if !dude.k.moving {
				s.countdown -= dt
				if s.countdown <= 0 {
					if entity_at_tile(dude^, dd[s.step]) {
						s.step += 1
						if s.step >= DUDE_NUM_DEST_2 {s.step = 0}
					}
					try_set_destination(&dude.k, dd[s.step])
					s.countdown = DUDE_PAUSE_2
				}
			}
		}
	case Talking:
		if s.tree == 1 {
			dt := DUDE_TEXT_1
			// if text[0].id != dt[s.line].id {
			if text.id == 0 {
				// append(&text, dt[s.line])
				fmt.println("setting text to", &dt[s.line])
				text = dt[s.line]
			}
		} else if s.tree == 2 {
			dt := DUDE_TEXT_2
			if text.id == 0 {
				text = dt[s.line]
			}
		}
	}
}

welcome := Text_Display {
	id = 12,
	text = "(Press spacebar to start)",
	on_end = proc(_: int) {
		set_entity_busy(PLAYER_ID, false)
	},
	wait = true,
}

start_level :: proc() {
	m = build_map()

	player := Entity {
		busy = true, // for welcome text
		id = PLAYER_ID,
		k = Kinematics{face = Direction_Vectors[.South], tile = DUDE_SPAWN, speed = 3},
		n = "Player",
		s = player_control,
		state = Control{},
		v = Visual_Solid_Rect{color = PLAYER_COLOR, size = TILE_DIM},
	}

	dude := Entity {
		k = Kinematics{tile = Tile_Coord{18, 10}, speed = 2},
		id = DUDE_ID,
		n = "Dude",
		s = dude_script,
		state = Pacing{route = 1},
		v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
	}

	append(&entities, player)
	append(&entities, dude)

	// append(&text, Text_Display {
	text = welcome
}
