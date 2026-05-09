package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

PLAYER_ID: Id = 0
DUDE_ID: Id = 1
BUTTON_1_ID: Id = 40

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
	Set_Entity_Talk_Script{id = DUDE_ID, script = DUDE_SCRIPT_1[:]},
	Set_Entity_State{id = DUDE_ID, state = Pacing{route = 1}},
	Set_Bool{k = .Met_Dude, v = true},
	Set_Entity_Busy{id = DUDE_ID, busy = false},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

DUDE_SCRIPT_1 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Append_Text{text = "Keep on keepin' on.", pause = .5, hurry = true},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

BUTTON_1_SCRIPT := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Set_Entity_Texture{id = BUTTON_1_ID, texture = .Button_Pressed},
	Append_Text{text = "*Beep*"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	Pause_Runner{1},
	Set_Entity_Texture{id = BUTTON_1_ID, texture = .Button},
	End{},
}

BUTTON_2_SCRIPT := [?]Event {
	Clear_Text{},
	Append_Text{text = "*Boop*", pause = .5, hurry = true},
	Close_Dialogue{},
	Clear_Text{},
	End{},
}

MONSTER_IN_A_BOX := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Append_Text{text = "Monster in a box!"},
	Close_Dialogue{},
	Clear_Text{},
	Start_Encounter{encounter = 0},
	Append_Text{text = "Didja win?"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

welcome := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Curtain_Up{},
	Append_Text{text = "[Press Z to start]"},
	Close_Dialogue{},
	Clear_Text{},
	Set_Bool{k = .Introduction, v = true},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
}

WARP_TO_0 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_0},
	Curtain_Up{},
	End{},
}
WARP_TO_1 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_1},
	Curtain_Up{},
	End{},
}
WARP_TO_2 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_2},
	Curtain_Up{},
	End{},
}

add_pc_entity :: proc(tile: Tile_Coord, face: Face) {
	pc_entity = hm.add(
		&entities,
		Entity {
			id = PLAYER_ID,
			face = face,
			tile = tile,
			speed = 3,
			n = "Player",
			state = Control{},
			v = facing_animation_create(
				.Protagonist_World_Left,
				.Protagonist_World_Right,
				.Protagonist_World_Up,
				.Protagonist_World_Down,
				face,
			),
			z = Z_MAX,
		},
	)
}

start_level_0 :: proc() {
	m = build_map()

	add_pc_entity(PLAYER_SPAWN, .Down)

	if get_game_data(Bool_Datum.Met_Dude) {
		_ = hm.add(
			&entities,
			Entity {
				id = DUDE_ID,
				face = .Down,
				tile = {10, 10},
				speed = 2,
				n = "Dude",
				talk = DUDE_SCRIPT_1[:],
				state = Pacing{route = 1, pause = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	} else {
		_ = hm.add(
			&entities,
			Entity {
				id = DUDE_ID,
				face = .Down,
				tile = DUDE_SPAWN,
				speed = 2,
				n = "Dude",
				talk = DUDE_SCRIPT_0[:],
				state = Pacing{route = 0, pause = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}

	_ = hm.add(
		&entities,
		Entity {
			id = 3,
			ghost = true,
			tile = Tile_Coord{12, 12},
			n = "warp",
			trap = WARP_TO_1[:],
			v = animation_create(.Warp),
		},
	)

	_ = hm.add(
		&entities,
		Entity {
			id = BUTTON_1_ID,
			tile = PLAYER_SPAWN + {1, 1},
			n = "Button 1",
			talk = BUTTON_1_SCRIPT[:],
			v = Texture_Name.Button,
		},
	)

	_ = hm.add(
		&entities,
		Entity{id = 50, tile = PLAYER_SPAWN + {2, 1}, n = "Button 2", talk = BUTTON_2_SCRIPT[:], v = Texture_Name.Button},
	)

	_ = hm.add(
		&entities,
		Entity {
			id = 100,
			tile = PLAYER_SPAWN + {-2, 0},
			n = "Monster in a box",
			talk = MONSTER_IN_A_BOX[:],
			v = Texture_Name.Box,
		},
	)

	if !get_game_data(Bool_Datum.Introduction) {
		start_script(welcome[:])
	}
}

GUY_ID :: 80

GUY_SCRIPT := [?]Event{
	Set_Entity_Busy{id = PLAYER_ID, busy=true},
	Set_Entity_Busy{id = GUY_ID, busy = true},
	Append_Text{text="Erm, hello, $player."},
	Clear_Text{},
	Append_Text{text="Have you met Dude yet? "},
	Skip_If{2, .Met_Dude},
	Append_Text{text="No? Well."},
	Skip{1},
	Append_Text{text="Yes? Very good."},
	Close_Dialogue{},
	Clear_Text{},
	Set_Entity_Busy{id = GUY_ID, busy = false},
	Set_Entity_Busy{id = PLAYER_ID, busy = false},
	End{},
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

	add_pc_entity(Tile_Coord{11, 11}, .Right)

	_ = hm.add(
		&entities,
		Entity {
			id = GUY_ID,
			face = .Down,
			tile = {16, 11},
			n = "Guy",
			talk = GUY_SCRIPT[:],
			v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
		}
	)
	_ = hm.add(
		&entities,
		Entity {
			id = 3,
			ghost = true,
			tile = Tile_Coord{15, 11},
			n = "warp",
			trap = WARP_TO_2[:],
			v = animation_create(.Warp),
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

	add_pc_entity(Tile_Coord{14, 14}, .Down)

	for i := 1; i <= MAP_WIDTH - 3; i += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 100 + i,
				tile = Tile_Coord{i, 1},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 200 + i,
				tile = Tile_Coord{i, MAP_HEIGHT - 3},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 3},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}
	for j := 3; j <= MAP_HEIGHT - 5; j += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 300 + j,
				tile = Tile_Coord{1, j},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 0},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 400 + j,
				tile = Tile_Coord{MAP_WIDTH - 3, j},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 2},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}

	_ = hm.add(
		&entities,
		Entity {
			id = 3,
			ghost = true,
			tile = Tile_Coord{12, 12},
			n = "warp",
			trap = WARP_TO_0[:],
			v = animation_create(.Warp),
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
	camera_entity = pc_entity
	time.stopwatch_stop(&stopwatch)
	fmt.println("Loaded level", l, "in", time.stopwatch_duration(stopwatch))
}
