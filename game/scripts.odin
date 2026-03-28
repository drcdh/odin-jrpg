package game

import "core:fmt"

import la "core:math/linalg"

player_control :: proc(_: f32, p: ^Entity) {
	input := get_direction_input()
	if (input.x != 0 || input.y != 0) {
		// fmt.println(input)
		try_set_destination(&p.k, p.k.tile + input)
	}
}


// Script :: struct($Data: typeid) {
// 	data: Data,
// 	f:    proc(_: f32, _: ^Entity, _: ^Data) -> bool,
// }
//
// pace :: Script(int) {
// 	data = 0,
// 	f = proc(dt: f32, entity: ^Entity, data: ^int) {
//
// 	},
// }

// Face :: struct {
// 	d: Direction,
// }
//
// Move :: struct {
// 	d: Direction,
// }
//
// Pause :: struct {
// 	elapsed: f32,
// 	wait:    f32,
// }
//
// Random_Face :: struct {
// 	r: [4]Direction,
// }
//
// Random_Move :: struct {
// 	r: [4]Direction,
// }
//
// Script_Step :: union {
// 	Face,
// 	Move,
// 	Pause,
// 	Random_Face,
// 	Random_Move,
// }
//
// Script :: struct {
// 	step:  uint,
// 	steps: []Script_Step,
// }
//
// run_script :: proc(dt: f32, script: ^Script, k: ^Kinematics, v: ^Visual) {
// 	switch step in script.steps[script.step] {
// 	case Face:
// 		set_face(k, step.d)
// 		return true
// 	case Move:
// 		try_set_destination(k, step.d)
// 		return true
// 	case Pause:
// 		step.elapsed += dt
// 		if step.elapsed >= step.wait {
// 			step.elapsed = 0
// 			return true
// 		}
// 		return false
// 	}
// }
