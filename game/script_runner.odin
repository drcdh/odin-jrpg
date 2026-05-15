package game

import hm "core:container/handle_map"
import "core:fmt"

Continue :: struct {}
Pause :: struct {
	countdown: f32,
}
Wait :: struct {}
Wait_Dialogue :: struct {}
Wait_Encounter :: struct {}
Wait_Transition :: struct {}

Script_State :: union {
	Continue,
	Pause,
	Wait,
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
		case Wait_Dialogue:
			if dialogue_done() {runner.state = Continue{}}
			return
		case Wait_Encounter:
			if !battle_active {runner.state = Continue{}}
			return
		case Wait_Transition:
			if curtain_t <= 0 {runner.state = Continue{}}
			return
		}

		fmt.printfln("% 4d: step %d - %w", frame_count, runner.step, runner.script[runner.step])
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
		case Battle_Unpause:
			battle_paused = false
		case Clear_Text:
			clear_dialogue()
		case Close_Dialogue:
			close_dialogue()
		case Curtain_Down:
			curtain_up = false
			curtain_t = CURTAIN_TIME
			runner.state = Wait_Transition{}
		case Curtain_Up:
			curtain_up = true
			curtain_t = CURTAIN_TIME
			runner.state = Wait_Transition{}
		case Move_Entity_Here:
			moving_entity := get_entity_p(event.id)
			if pc, ok := hm.get(&entities, pc_entity); ok {
				moving_entity.tile = pc.tile
				fmt.printfln("% 4d: moved entity %s to %s at %w", frame_count, moving_entity.n, pc.n, pc.tile)
			}
		case Play_Animation:
			// todo
		case Play_Sound:
			play_sound(event.sound)
		case Remove_Entity:
			remove_entity(event.id)
		case Set_Boat_Control:
			boat := get_entity_p(BOAT_ID)
			boat.state = Control{}
			boat_mode = true
			pc_entity = boat_handle
			camera_entity = boat_handle
		case Set_Bool:
			set_game_data(event.k, event.v)
		case Set_Int:
			set_game_data(event.k, event.v)
		case Set_Entity_Busy:
			set_entity_busy(event.id, event.busy)
		case Set_Entity_Disabled:
			set_entity_disabled(event.id, event.disabled)
		case Set_Entity_Talk_Script:
			set_entity_talk_script(event.id, event.script)
		case Set_Entity_Trap_Script:
			set_entity_trap_script(event.id, event.script)
		case Set_Entity_State:
			set_entity_state(event.id, event.state)
		case Set_Entity_Texture:
			set_entity_visual(event.id, event.texture)
		case Set_Party_Control:
			set_party_control()
		case Skip:
			runner.step += event.n
		case Skip_If:
			if get_game_data(event.d) {
				runner.step += event.n
			}
		case Start_Encounter:
			start_encounter(event.encounter, event.paused)
		case Start_Level:
			start_level(event.level)
		case Start_Next_Level:
			start_level(next_level)
		case Wait_Encounter_R:
			runner.state = Wait_Encounter{}
		}
	}
}
