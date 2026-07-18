package game

import "core:container/queue"
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
Event_Queue :: queue.Queue(Event)

Runner :: struct {
	events: Event_Queue,
	state:  Script_State,
}

runner := Runner{}

queue_events :: proc(events: []Event) {
	queue.push_back_elems(&runner.events, ..events)
}

queue_events_front :: proc(events: []Event) {
	#reverse for event in events {
		queue.push_front(&runner.events, event)
	}
}

runner_len :: proc() -> int {
	return queue.len(runner.events)
}

runner_current_event :: proc() -> Event {
	return queue.front(&runner.events)
}

update_runner :: proc(dt: f32) {
	if runner_len() > 0 {
		switch &state in runner.state {
		case Continue:
			queue.consume_front(&runner.events, 1)
			if runner_len() == 0 {
				runner.state = nil
				return
			}
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
		fmt.printfln("% 4d: %w || %w", frame_count, runner.state, runner_current_event())
		process_event(runner_current_event())
		if runner.state == nil {runner.state = Continue{}}
	}
}
