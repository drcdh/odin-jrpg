package game

Append_Text :: struct {
	text:  string,
	hurry: bool,
	pause: f32,
}
Clear_Text :: struct {}
Close_Dialogue :: struct {}
End :: struct {}
Pause_Runner :: struct {
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
Start_Encounter :: struct {
	encounter: int,
}
Start_Level :: struct {
	level: Level,
}

Event :: union {
	Append_Text,
	Clear_Text,
	Close_Dialogue,
	End,
	Pause_Runner,
	Set_Entity_Busy,
	Set_Entity_Script,
	Set_Entity_State,
	Start_Encounter,
	Start_Level,
}

Continue :: struct {}
Pause :: struct {
	countdown: f32,
}
Wait :: struct {}
Wait_Dialogue :: struct {}

Script_State :: union {
	Continue,
	Pause,
	Wait,
	Wait_Dialogue,
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
		case Wait_Dialogue:
			if dialogue_done() {runner.state = Continue{}}
			return
		}

		switch event in runner.script[runner.step] {
		case Append_Text:
			queue_dialogue(event.text, event.hurry, event.pause)
			runner.state = Wait_Dialogue{}
		case End:
			runner.script = nil
		case Pause_Runner:
			runner.state = Pause {
				countdown = event.duration,
			}
		case Clear_Text:
			clear_dialogue()
		case Close_Dialogue:
			close_dialogue()
		case Set_Entity_Busy:
			set_entity_busy(event.id, event.busy)
		case Set_Entity_Script:
			set_entity_script(event.id, event.script)
		case Set_Entity_State:
			set_entity_state(event.id, event.state)
		case Start_Encounter:
			start_encounter(event.encounter)
		case Start_Level:
			start_level(event.level)
		}
	}
}
