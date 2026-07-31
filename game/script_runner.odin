package game

import hm "core:container/handle_map"
import "core:container/queue"
import "core:fmt"

Runner_State :: enum {
	Start,
	Continue,
	Pause,
	Wait,
	Wait_Choice,
	Wait_Dialogue,
	Wait_Encounter,
	Wait_Transition,
}

Event_Queue :: queue.Queue(Event)

Runner :: struct {
	battle: bool,
	events: Event_Queue,
	pause:  f32,
	state:  Runner_State,
}

runners: [dynamic]Runner

delete_runners :: proc() {
	// call when game quits
	for &runner in runners {
		queue.destroy(&runner.events)
	}
	delete(runners)
}

queue_events :: proc(events: []Event, i: Maybe(int) = nil, battle := false) -> int {
	if runner_idx, ok := i.?; ok {
		queue.push_back_elems(&runners[runner_idx].events, ..events)
		return runner_idx
	}
	runner_idx := len(runners)
	append(&runners, Runner{battle = battle})
	queue.push_back_elems(&runners[runner_idx].events, ..events)
	return runner_idx
}

// runner_queue_front :: proc(events: []Event) {
// 	#reverse for event in events {
// 		queue.push_front(&runner.events, event)
// 	}
// }

runner_len :: proc(runner: Runner) -> int {
	return queue.len(runner.events)
}

runner_current :: proc(runner: ^Runner) -> Event {
	return queue.front(&runner.events)
}

update_runners :: proc(dt: f32) {
	for &runner in runners {
		update_runner(&runner, dt)
	}
}

update_runner :: proc(runner: ^Runner, dt: f32) {
	if runner_len(runner^) > 0 {
		switch runner.state {
		case .Start:
		case .Continue:
			queue.consume_front(&runner.events, 1)
			if runner_len(runner^) == 0 {
				runner.state = .Start
				return
			}
		case .Pause:
			runner.pause -= dt
			if runner.pause <= 0 {runner.state = .Continue}
			return
		case .Wait:
			if get_input(Game_Input.ENTER) {runner.state = .Continue}
			return
		case .Wait_Choice:
			if dialogue_choice_made != nil {runner.state = .Continue}
			return
		case .Wait_Dialogue:
			if dialogue_done() {runner.state = .Continue}
			return
		case .Wait_Encounter:
			if !battle.active {runner.state = .Continue}
			return
		case .Wait_Transition:
			if transition_done() {runner.state = .Continue}
			return
		}
		fmt.printfln("% 4d: %w || %w", frame_count, runner.state, runner_current(runner))
		process_event(runner)
		if runner.state == .Start {runner.state = .Continue}
	}
}

process_event :: proc(runner: ^Runner) {
	switch event in runner_current(runner) {
	case Add_Item:
		add_item(event.item, event.number)
	case Append_Text:
		queue_dialogue(event.text, event.hurry, event.pause)
		runner.state = .Wait_Dialogue
	case Append_Choice:
		append(&dialogue_choices, event.text)
	case Battle_Unpause:
		battle.paused = false
	case Clear_Text:
		clear_dialogue()
	case Close_Dialogue:
		close_dialogue()
	case Curtain_Down:
		curtain_down(event.type)
		runner.state = .Wait_Transition
	case Curtain_Up:
		curtain_up(event.type)
		runner.state = .Wait_Transition
	case End:
		runner.state = .Continue
	case Get_Choice:
		dialogue_choice_made = nil
		dialogue_state = Dialogue_Choose{}
		runner.state = .Wait_Choice
	case Heal_Party:
		heal_party()
	case Lose_Money:
		game_data.money -= event.m
		if game_data.money < 0 {game_data.money = 0}
	case Move_Entity_Here:
		moving_entity := get_entity_p(event.id)
		if pc, ok := hm.get(&entities, pc_entity); ok {
			moving_entity.tile = pc.tile
			fmt.printfln("% 4d: moved entity %s to %s at %w", frame_count, moving_entity.n, pc.n, pc.tile)
		}
	case Pause_Runner:
		runner.pause = event.pause
		runner.state = .Pause
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
		queue.consume_front(&runner.events, event.n)
	case Skip_If:
		if get_game_data(event.d) {
			queue.consume_front(&runner.events, event.n)
		}
	case Skip_If_Choice:
		if dialogue_choice_made == event.c {
			queue.consume_front(&runner.events, event.n)
		}
	case Skip_If_Have_Money:
		if game_data.money >= event.m {
			queue.consume_front(&runner.events, event.n)
		}
	case Start_Encounter:
		start_encounter(event.encounter, event.paused)
	case Start_Level:
		start_level(event.level)
	case Start_Next_Level:
		start_level(next_level)
	case Toggle_Party_Member:
		game_data.party_membership[event.pc_idx] = event.join
	case Wait_Encounter:
		runner.state = .Wait_Encounter
	}
}
