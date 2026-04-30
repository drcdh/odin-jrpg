package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

PLAYER_ID: Id = 0
DUDE_ID: Id = 1

DUDE_COLOR :: rl.Color{80, 80, 90, 255}
PLAYER_COLOR :: rl.Color{200, 120, 120, 255}

PLAYER_SPAWN :: Tile_Coord{15, 15}
DUDE_SPAWN :: Tile_Coord{18, 10}

LEVEL_ROUTES := [][]Tile_Coord {
	{{18, 10}, {18, 8}, {16, 8}, {16, 10}},
	{{10, 10}, {10, 14}},
	{{1, 1}, {MAP_WIDTH - 3, 1}, {MAP_WIDTH - 3, MAP_HEIGHT - 3}, {1, MAP_HEIGHT - 3}},
}

DUDE_SCRIPT_0 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Set_Entity_Busy{id = DUDE_ID, busy = true},
	Append_Text{text = "Oh, hey! What's up, $player?"},
	Clear_Text{},
	Append_Text{text = "Anyway, I'm going over there now."},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Script{id = DUDE_ID, script = DUDE_SCRIPT_1[:]},
	Set_Entity_State{id = DUDE_ID, state = Pacing{route = 1}},
	Set_Entity_Busy{id = DUDE_ID, busy = false},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

DUDE_SCRIPT_1 := [?]Event{Append_Text{text = "Keep on keepin' on."}, Close_Dialogue{}, Clear_Text{}, End{}}

welcome := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Append_Text{text = "(Press spacebar to start)"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

WARP_TO_0 := [?]Event{Set_Entity_Busy{id = PLAYER_ID, busy = true}, Start_Level{level = .LEVEL_0}, End{}}

WARP_TO_1 := [?]Event{Set_Entity_Busy{id = PLAYER_ID, busy = true}, Start_Level{level = .LEVEL_1}, End{}}

WARP_TO_2 := [?]Event{Set_Entity_Busy{id = PLAYER_ID, busy = true}, Start_Level{level = .LEVEL_2}, End{}}

add_pc_entity :: proc(tile, face: Tile_Coord) {
	pc_entity = hm.add(
		&entities,
		Entity {
			id = PLAYER_ID,
			k = Kinematics{face = face, tile = tile, speed = 3},
			n = "Player",
			script = nil,
			state = Control{},
			v = Visual_Solid_Rect{color = PLAYER_COLOR, size = TILE_DIM},
		},
	)
}

start_level_0 :: proc() {
	m = build_map()

	add_pc_entity(PLAYER_SPAWN, Direction_Vectors[.South])

	dude := hm.add(
		&entities,
		Entity {
			id = DUDE_ID,
			k = Kinematics{face = Direction_Vectors[.South], tile = DUDE_SPAWN, speed = 2},
			n = "Dude",
			script = DUDE_SCRIPT_0[:],
			state = Pacing{route = 0, pause = 1},
			v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
		},
	)

	warp := hm.add(
		&entities,
		Entity {
			id = 3,
			k = Kinematics{tile = Tile_Coord{10, 10}},
			n = "warp",
			script = WARP_TO_1[:],
			v = Visual_Solid_Circle{color = rl.Color{200, 0, 200, 255}, radius = TILE_SIZE / 2},
		},
	)

	start_script(welcome[:])
}

start_level_1 :: proc() {
	{
		m = Map{}
		for i in 10 ..= 18 {
			for j in 10 ..= 13 {
				m[i][j] = 1
			}
		}
	}

	add_pc_entity(Tile_Coord{11, 11}, Direction_Vectors[.East])

	warp := hm.add(
		&entities,
		Entity {
			id = 3,
			k = Kinematics{tile = Tile_Coord{15, 11}},
			n = "warp",
			script = WARP_TO_2[:],
			v = Visual_Solid_Circle{color = rl.Color{200, 0, 200, 255}, radius = TILE_SIZE / 2},
		},
	)
}

start_level_2 :: proc() {
	{
		m = Map{}
		for i in 0 ..< MAP_WIDTH {
			for j in 0 ..< MAP_HEIGHT {
				m[i][j] = 1
			}
		}
	}

	add_pc_entity(Tile_Coord{14, 14}, Direction_Vectors[.East])

	for i := 1; i <= MAP_WIDTH - 3; i += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 100 + i,
				k = Kinematics{tile = Tile_Coord{i, 1}, speed = 2},
				state = Pacing{route = 2, pause = 1, step = 1},
				v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 200 + i,
				k = Kinematics{tile = Tile_Coord{i, MAP_HEIGHT - 3}, speed = 2},
				state = Pacing{route = 2, pause = 1, step = 3},
				v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
			},
		)
	}
	for j := 3; j <= MAP_HEIGHT - 5; j += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 300 + j,
				k = Kinematics{tile = Tile_Coord{1, j}, speed = 2},
				state = Pacing{route = 2, pause = 1, step = 0},
				v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 400 + j,
				k = Kinematics{tile = Tile_Coord{MAP_WIDTH - 3, j}, speed = 2},
				state = Pacing{route = 2, pause = 1, step = 2},
				v = Visual_Solid_Rect{color = DUDE_COLOR, size = TILE_DIM},
			},
		)
	}

	warp := hm.add(
		&entities,
		Entity {
			id = 3,
			k = Kinematics{tile = Tile_Coord{12, 12}},
			n = "warp",
			script = WARP_TO_0[:],
			v = Visual_Solid_Circle{color = rl.Color{200, 0, 200, 255}, radius = TILE_SIZE / 2},
		},
	)
}

Level :: enum {
	LEVEL_0,
	LEVEL_1,
	LEVEL_2,
}

start_level :: proc(l: Level) {
	hm.clear(&entities)
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)
	switch l {
	case .LEVEL_0:
		start_level_0()
	case .LEVEL_1:
		start_level_1()
	case .LEVEL_2:
		start_level_2()
	}
	time.stopwatch_stop(&stopwatch)
	fmt.println("Loaded level", l, "in", time.stopwatch_duration(stopwatch))
}
