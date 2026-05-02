package game

import "core:fmt"
import "core:strings"

Append_Text :: struct {
	// hurry: bool,
	// pause: f32,
	text: cstring,
}
Clear_Text :: struct {}
Close_Dialogue :: struct {}
End :: struct {}
Pause_Dialogue :: struct {
	duration: f32,
}
Set_Entity_Busy :: struct {
	id:   Id,
	busy: bool,
}
Set_Entity_Script :: struct {
	id:     Id,
	script: []Event,
}
Set_Entity_State :: struct {
	id:    Id,
	state: State,
}
Start_Level :: struct {
	level: Level,
}

Event :: union {
	Append_Text,
	Clear_Text,
	Close_Dialogue,
	End,
	Pause_Dialogue,
	Set_Entity_Busy,
	Set_Entity_Script,
	Set_Entity_State,
	Start_Level,
}

Continue :: struct {}
Pause :: struct {
	countdown: f32,
}
Wait :: struct {}

Script_State :: union {
	Continue,
	Pause,
	Wait,
}

Runner :: struct {
	script: []Event,
	state:  Script_State,
	step:   int,
}

start_script :: proc(script: []Event) {
	if script != nil {
		fmt.println("starting script of len", len(script))
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
			// fmt.println("paused:", state.countdown)
			if state.countdown <= 0 {runner.state = Continue{}}
			return
		case Wait:
			if get_input(Game_Input.ENTER) {runner.state = Continue{}}
			return
		}

		// fmt.println("Start event", runner.script[runner.step])

		switch event in runner.script[runner.step] {
		case Append_Text:
			dialogue_show = true
			dialogue_str = strings.concatenate({dialogue_str, string(event.text)})
			fmt.println(event.text)
			// if !event.hurry {
			// 	fmt.println("[waiting]")
			runner.state = Wait{}
		// } else {
		// 	fmt.println("[hurry]")
		// }
		case End:
			runner.script = nil
		case Pause_Dialogue:
			// fmt.println("[pause]")
			runner.state = Pause {
				countdown = event.duration,
			}
		case Clear_Text:
			delete(dialogue_str)
			dialogue_str = ""
		// fmt.println("<clear>")
		case Close_Dialogue:
			dialogue_show = false
		// fmt.println("<close>")
		case Set_Entity_Busy:
			set_entity_busy(event.id, event.busy)
		case Set_Entity_Script:
			set_entity_script(event.id, event.script)
		case Set_Entity_State:
			set_entity_state(event.id, event.state)
		case Start_Level:
			start_level(event.level)
		}
	}
}
