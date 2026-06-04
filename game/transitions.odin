package game

import rl "vendor:raylib"

TRANSITION_TIME :: .5 // seconds

Transition_Type :: enum {
	Level,
	Battle,
}

Transition :: struct {
	curtain_up: bool,
	t:          f32,
	type:       Transition_Type,
}

transition: Transition

curtain_up :: proc(type: Transition_Type) {
	transition.curtain_up = true
	transition.t = TRANSITION_TIME
	transition.type = type
}

curtain_down :: proc(type: Transition_Type) {
	transition.curtain_up = false
	transition.t = TRANSITION_TIME
	transition.type = type
}

transition_done :: proc() -> bool {
	return transition.t <= 0
}

draw_transition :: proc() {
	switch transition.type {
	case .Battle:
		draw_battle_transition()
	case .Level:
		draw_level_transition()
	}
}

draw_battle_transition :: proc() {
	if transition.t > 0 {
		ease := transition.t / TRANSITION_TIME
		if !transition.curtain_up {ease = 1 - ease}
		w := f32(ease * view_dim.x)
		h := 10 * f32(ease * view_dim.y)
		rl.DrawEllipse(i32(view_dim.x / 2), i32(view_dim.y / 2), h, w, rl.BLACK)
	} else if !transition.curtain_up {
		rl.ClearBackground(rl.BLACK)
	}
}

draw_level_transition :: proc() {
	if transition.t > 0 {
		ease := transition.t / TRANSITION_TIME
		if !transition.curtain_up {ease = 1 - ease}
		w := i32(ease * view_dim.x)
		h := i32(ease * view_dim.y)
		x0 := i32(view_dim.x / 2) - w / 2
		y0 := i32(view_dim.y / 2) - h / 2
		rl.DrawRectangle(x0, y0, w, h, rl.BLACK)
	} else if !transition.curtain_up {
		rl.ClearBackground(rl.BLACK)
	}
}

update_transition :: proc() {
	if transition.t > 0 {
		transition.t -= rl.GetFrameTime()
	}
}
