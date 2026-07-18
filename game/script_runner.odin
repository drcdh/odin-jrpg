package game

import "core:fmt"

Continue :: struct {}
Pause :: struct {
	countdown: f32,
}
Wait :: struct {}
Wait_Choice :: struct {}
Wait_Dialogue :: struct {}
Wait_Encounter :: struct {}
Wait_Transition :: struct {}

Script_State :: union {
	Continue,
	Pause,
	Wait,
	Wait_Choice,
	Wait_Dialogue,
	Wait_Encounter,
	Wait_Transition,
}

Runner :: struct {
	script: []Event,
	state:  Script_State,
	step:   int,
}

start_script :: proc(script: []Event) {
	if script != nil {
		runner.script = script
		runner.state = Continue{}
		runner.step = -1
	}
}

update_runner :: proc(dt: f32) {
	if runner.script != nil {
		switch &state in runner.state {
		case Continue:
			runner.step += 1
		case Pause:
			state.countdown -= dt
			if state.countdown <= 0 {runner.state = Continue{}}
			return
		case Wait:
			if get_input(Game_Input.ENTER) {runner.state = Continue{}}
			return
		case Wait_Choice:
			if dialogue_choice_made != nil {runner.state = Continue{}}
			return
		case Wait_Dialogue:
			if dialogue_done() {runner.state = Continue{}}
			return
		case Wait_Encounter:
			if !battle.active {runner.state = Continue{}}
			return
		case Wait_Transition:
			if transition_done() {runner.state = Continue{}}
			return
		}

		fmt.printfln("% 4d: step %d - %w", frame_count, runner.step, runner.script[runner.step])
		process_event(runner.script[runner.step])
	}
}
