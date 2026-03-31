package game

import "core:fmt"
import rl "vendor:raylib"

PLAYER_ID: Id = 0
DUDE_ID: Id = 1

DUDE_COLOR :: rl.Color{80, 80, 90, 255}
PLAYER_COLOR :: rl.Color{200, 120, 120, 255}

PLAYER_SPAWN :: Tile_Coord{15, 15}
DUDE_SPAWN :: Tile_Coord{18, 10}

LEVEL_ROUTES := [][]Tile_Coord{
	{{18, 10}, {18, 8}, {16, 8}, {16, 10}},
{{10, 10}, {10, 14}},
}

Control :: struct {}

Pacing :: struct {
	countdown: f32,
	pause: f32,
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
}

dude_0 := []Event {
	Set_Entity_Busy{id=PLAYER_ID, busy=true},
	Set_Entity_Busy{id=DUDE_ID, busy=true},
	Append_Text{text="Oh, hey! What's up, $player?"},
	Append_Text{text="Anyway, I'm going over there now."},
	Close_Dialogue{},
	Set_Entity_Script{id=DUDE_ID, script=dude_1},
	Set_Entity_State{id=DUDE_ID, state=Pacing{route=1}},
	Set_Entity_Busy{id=DUDE_ID, busy=false},
	Set_Entity_Busy{id=PLAYER_ID, busy=false},
	End{},
}

dude_1 := []Event {
	Append_Text{text="Keep on keepin' on.", hurry=true, pause=2},
	Close_Dialogue{},
	End{},
}

welcome := []Event {
	Set_Entity_Busy{id=PLAYER_ID, busy=true},
	Append_Text{text="(Press spacebar to start)"},
	Close_Dialogue{},
	Set_Entity_Busy{id=PLAYER_ID, busy=false},
	End{},
}

start_level :: proc() {
	m = build_map()

	player := Entity {
		id = PLAYER_ID,
		k = Kinematics{face = Direction_Vectors[.South], tile = PLAYER_SPAWN, speed = 3},
		n = "Player",
		script = nil,
		state = Control{},
		v = Visual_Solid_Rect{color = PLAYER_COLOR, size = TILE_DIM},
	}

	dude := Entity {
		id = DUDE_ID,
		k = Kinematics{face = Direction_Vectors[.South], tile = DUDE_SPAWN, speed = 2},
		n = "Dude",
		script = dude_0,
		state = Pacing{route = 0, pause = 1},
		v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
	}

	append(&entities, player)
	append(&entities, dude)

	start_script(welcome)
}
