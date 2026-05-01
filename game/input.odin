package game

import rl "vendor:raylib"

HOLD_TIME :: 1 // second

// These are player inputs that the game understands.
// These will be (re)mapped to keyboard or controller buttons
Game_Input :: enum {
	ENTER,
	CANCEL,
	MENU,
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

GAME_INPUTS :: [?]Game_Input{.ENTER, .CANCEL, .MENU, .UP, .DOWN, .LEFT, .RIGHT}

INPUT_MAP: map[Game_Input]rl.KeyboardKey

Input_Up :: struct {}
Input_Pressed :: struct {}
Input_Held :: struct {
	t: f32,
}
Single_Input_State :: union {
	Input_Up,
	Input_Pressed,
	Input_Held,
}

input_state : map[Game_Input]Single_Input_State

initialize_input :: proc() {
	INPUT_MAP[Game_Input.ENTER] = rl.KeyboardKey.Z
	INPUT_MAP[Game_Input.CANCEL] = rl.KeyboardKey.X
	INPUT_MAP[Game_Input.MENU] = rl.KeyboardKey.S
	INPUT_MAP[Game_Input.UP] = rl.KeyboardKey.UP
	INPUT_MAP[Game_Input.DOWN] = rl.KeyboardKey.DOWN
	INPUT_MAP[Game_Input.LEFT] = rl.KeyboardKey.LEFT
	INPUT_MAP[Game_Input.RIGHT] = rl.KeyboardKey.RIGHT

	input_state[.ENTER  ]= Input_Up{}
	input_state[.CANCEL ]= Input_Up{}
	input_state[.MENU   ]= Input_Up{}
	input_state[.UP     ]= Input_Up{}
	input_state[.DOWN   ]= Input_Up{}
	input_state[.LEFT   ]= Input_Up{}
	input_state[.RIGHT  ]= Input_Up{}
}

get_updated_input_state :: proc(dt: f32, k: rl.KeyboardKey, s: Single_Input_State) -> Single_Input_State {
	if rl.IsKeyDown(k) {
		switch s in s {
		case Input_Up:
			return Input_Pressed{}
		case Input_Pressed:
			return Input_Held{t = dt}
		case Input_Held:
			return Input_Held{t = dt + s.t}
		}
	}
	if rl.IsKeyUp(k) {return Input_Up{}}
	return nil
}

update_input_state :: proc(dt: f32) {
	for k in GAME_INPUTS {
		input_state[k] = get_updated_input_state(dt, INPUT_MAP[k], input_state[k])
	}
	// input_state[.ENTER] = get_updated_input_state(dt, INPUT_MAP[.ENTER], input_state[.ENTER])
	// input_state[.CANCEL] = get_updated_input_state(dt, INPUT_MAP[.CANCEL], input_state[.CANCEL])
	// input_state[.MENU] = get_updated_input_state(dt, INPUT_MAP[.MENU], input_state[.MENU])
	// input_state[.UP] = get_updated_input_state(dt, INPUT_MAP[.UP], input_state[.UP])
	// input_state[.DOWN] = get_updated_input_state(dt, INPUT_MAP[.DOWN], input_state[.DOWN])
	// input_state[.LEFT] = get_updated_input_state(dt, INPUT_MAP[.LEFT], input_state[.LEFT])
	// input_state[.RIGHT] = get_updated_input_state(dt, INPUT_MAP[.RIGHT], input_state[.RIGHT])
}

get_input :: proc(k: Game_Input, down:=false, silent:=false) -> (v := false) {
	switch s in input_state[k] {
	case Input_Up:
		v = false
	case Input_Pressed:
		v = true
	case Input_Held:
		v = down || s.t >= HOLD_TIME
	}
	if v && !silent {
		play_sound(.UI_Blip)
	}
	return
}

get_direction_input :: proc() -> (m := Tile_Coord{}) {
	if get_input(.UP, true, true) {
		m.y -= 1
	}
	if get_input(.DOWN, true, true) {
		m.y += 1
	}
	if get_input(.LEFT, true, true) {
		m.x -= 1
	}
	if get_input(.RIGHT, true, true) {
		m.x += 1
	}
	return
}

get_y_input :: proc() -> Maybe(int) {
	v := 0
	if get_input(.UP) {
		v -= 1
	}
	if get_input(.DOWN) {
		v += 1
	}
	if v != 0 {
		return v
	}
	return nil
}
