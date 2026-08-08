package game

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
	Working,
}

Event_Queue :: queue.Queue(Event)

Runner :: struct {
	battle: bool,
	events: Event_Queue,
	pause:  f32,
	state:  Runner_State,
	wait_r: int, // FIXME: bad way to do this
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
	for i := 0; i < len(runners); {
		if runner_len(runners[i]) <= 0 {
			queue.destroy(&runners[i].events)
			unordered_remove(&runners, i)
		} else {
			if !battle.active || runners[i].battle {
				update_runner(&runners[i], dt)
			}
			i += 1
		}
	}
}

update_runner :: proc(runner: ^Runner, dt: f32) {
	if runner_len(runner^) > 0 {
		switch runner.state {
		case .Start:
		case .Continue:
			queue.consume_front(&runner.events, 1)
			if runner_len(runner^) == 0 {
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
		case .Working:
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
		dialogue_lines = DEFAULT_DIALOGUE_LINES
		queue_dialogue(event.text)
		runner.state = .Wait_Dialogue
	case Append_Text_Ex:
		if event.lines > 0 {
			dialogue_lines = event.lines
		} else {
			dialogue_lines = DEFAULT_DIALOGUE_LINES
		}
		queue_dialogue(event.text, event.hurry, event.pause)
		runner.state = .Wait_Dialogue
	case Append_Choice:
		append(&dialogue_choices, event.text)
	case Battle_Deactivate:
		battle_deactivate()
	case Battle_Pause:
		battle.paused = true
	case Battle_Unpause:
		battle.paused = false
	case Clear_Text:
		clear_dialogue()
	case Close_Dialogue:
		close_dialogue()
	case Combatant_Transition:
		runner.state = .Continue if combatant_transition(event.c_idx) else .Working
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
	case Load_Game:
		load_saved_game(event.save_data)
		start_menu_exit()
		start_save_point(event.save_data.save_point)
	case Lose_Money:
		game_data.money -= event.m
		if game_data.money < 0 {game_data.money = 0}
	case Move_Entity_Here:
		moving_entity := get_world_entity(event.id)
		if pc := get_world_entity(pc_handle); pc != nil {
			moving_entity.tile = pc.tile
			fmt.printfln("% 4d: moved entity %s to %s at %w", frame_count, moving_entity.n, pc.n, pc.tile)
		}
	case Music_Fade_Down:
		music_fade_down(&music_state)
	case Music_Fade_Up:
		music_fade_up(&music_state)
	case New_Game:
		init_new_game()
		start_menu_exit()
		start_level(.Level_0)
	case Pause_Runner:
		runner.pause = event.pause
		runner.state = .Pause
	case Play_Animation:
	// todo
	case Play_Prev_Music:
		play_prev_music(&music_state)
	case Play_Sound:
		play_sound(event.sound)
	case Quit:
		quitting = true
	case Remove_Entity:
		remove_world_entity(event.id)
	case Reset_Save_Points:
		reset_save_points()
	case Restart_Level:
		restart_level()
	case Save_Game:
		save_game(event.save_point)
	case Set_Boat_Control:
		boat := get_world_entity(BOAT_ID)
		boat.state = Control{}
		boat_mode = true
		pc_handle = boat_handle
		camera_handle = boat_handle
	case Set_Bool:
		set_game_data(event.k, event.v)
	case Set_Int:
		set_game_data(event.k, event.v)
	case Set_Entity_Busy:
		set_world_entity_busy(event.id, event.busy)
	case Set_Entity_Disabled:
		set_world_entity_disabled(event.id, event.disabled)
	case Set_Entity_Face_Party:
		set_world_entity_face_party(event.id)
	case Set_Entity_Sprite:
		set_world_entity_sprite(event.id, event.sprite)
	case Set_Entity_State:
		set_world_entity_state(event.id, event.state)
	case Set_Entity_Tag:
		set_world_entity_tag(event.id, event.tag, true)
	case Set_Entity_Talk_Script:
		set_world_entity_talk_script(event.id, event.script)
	case Set_Entity_Trap_Script:
		set_world_entity_trap_script(event.id, event.script)
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
