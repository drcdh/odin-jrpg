package game

import "core:fmt"
import rl "vendor:raylib"

Game_Input :: enum {
	ENTER,
	CANCEL,
	MENU,
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

FRAME_INPUT :: struct {
	enter, cancel, menu, left, right, up, down: bool,
}

frame_input := FRAME_INPUT{}

capture_input :: proc() {
	frame_input.enter = rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.Z)
	frame_input.cancel = rl.IsKeyPressed(.DELETE) || rl.IsKeyPressed(.X)
	frame_input.menu = rl.IsKeyPressed(.S)
	frame_input.left = rl.IsKeyDown(.LEFT)
	frame_input.right = rl.IsKeyDown(.RIGHT)
	frame_input.up = rl.IsKeyDown(.UP)
	frame_input.down = rl.IsKeyDown(.DOWN)
	// fmt.println(frame_input)
}

get_input :: proc(k: Game_Input, consume := true, consume_all := true) -> (v := false) {
	// fmt.println("get", frame_input)
	switch k {
	case .ENTER:
		if frame_input.enter {if consume {frame_input.enter = false};v = true}
	case .CANCEL:
		if frame_input.cancel {if consume {frame_input.cancel = false};v = true}
	case .MENU:
		if frame_input.menu {if consume {frame_input.menu = false};v = true}
	case .LEFT:
		if frame_input.left {if consume {frame_input.left = false};v = true}
	case .RIGHT:
		if frame_input.right {if consume {frame_input.right = false};v = true}
	case .UP:
		if frame_input.up {if consume {frame_input.up = false};v = true}
	case .DOWN:
		if frame_input.down {if consume {frame_input.down = false};v = true}
	}
	if v && consume_all {frame_input = FRAME_INPUT{}}
	// fmt.println("get_input:", k, consume, v, frame_input)
	return
}

get_direction_input :: proc(consume := true, consume_all := true) -> Tile_Coord {
	input: Tile_Coord
	if get_input(.UP, consume, false) {
		input.y -= 1
	}
	if get_input(.DOWN, consume, false) {
		input.y += 1
	}
	if get_input(.LEFT, consume, false) {
		input.x -= 1
	}
	if get_input(.RIGHT, consume, false) {
		input.x += 1
	}
	if input.x != 0 || input.y != 0 {
		if consume_all {frame_input = FRAME_INPUT{}}
	}
	return input
}
