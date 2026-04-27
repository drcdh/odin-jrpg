package game

import "core:fmt"
import "core:strings"

battle_hack := true
hack := true

player_control :: proc(_: f32, p: ^Entity) {
	// todo: check update_entity for redundant checks
	if !p.k.moving && !p.busy && !p.disabled {
		input := get_direction_input()
		if (input.x != 0 || input.y != 0) {
			try_set_destination(&p.k, p.k.tile + input)
		} else {
			if get_input(.ENTER) {
				if entity_in_front, ok := get_entity_at_tile(tile_in_front(p)).?; ok {
					activate_entity_idx(entity_in_front)
				}
				// fmt.println("TODO")
				// if battle_hack {
				// 	if battle_active {
				// 		battle_active = false
				// 	} else {
				// 		start_encounter_0()
				// 		battle_hack = false
				// 	}
				// } else if hack {
				// 	//fixme HACK
				// 	start_entity_script(DUDE_ID)
				// 	// hack = false
				// }
			}
		}
	}
}

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

Event :: union {
	Append_Text,
	Clear_Text,
	Close_Dialogue,
	End,
	Pause_Dialogue,
	Set_Entity_Busy,
	Set_Entity_Script,
	Set_Entity_State,
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
			fmt.println("[pause]")
			runner.state = Pause {
				countdown = event.duration,
			}
		case Clear_Text:
			dialogue_str = ""
			fmt.println("<clear>")
		case Close_Dialogue:
			dialogue_show = false
			fmt.println("<close>")
		case Set_Entity_Busy:
			set_entity_busy(event.id, event.busy)
		case Set_Entity_Script:
			set_entity_script(event.id, event.script)
		case Set_Entity_State:
			set_entity_state(event.id, event.state)
		}
	}
}
