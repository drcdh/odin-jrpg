package game

import hm "core:container/handle_map"
import "core:container/queue"
import "core:fmt"
import rl "vendor:raylib"

Add_Item :: struct {
	item:   Item_Name,
	number: u8,
}
Append_Text :: struct {
	text:  string,
	hurry: bool,
	pause: f32,
}
Append_Choice :: struct {
	text: string,
}
Battle_Unpause :: struct {}
Clear_Text :: struct {}
Close_Dialogue :: struct {}
End :: struct {}
Get_Choice :: struct {}
Pause_Runner :: struct {
	duration: f32,
}
Curtain_Down :: struct {
	type: Transition_Type,
}
Curtain_Up :: struct {
	type: Transition_Type,
}
Effect_Event :: struct {
	effect_name: Effect_Name,
	actor:       ^Character,
	target:      ^Character,
	value:       int,
}
Heal_Party :: struct {}
Lose_Money :: struct {
	m: Money,
}
Move_Entity_Here :: struct {
	id: Id,
}
Play_Animation :: struct {
	animation: Animation_Name,
	offset:    Pixel_Coord,
}
Play_Sound :: struct {
	delay: f32,
	sound: Sound_Name,
}
Remove_Entity :: struct {
	id: Id,
}
Set_Boat_Control :: struct {}
Set_Bool :: struct {
	k: Bool_Datum,
	v: bool,
}
Set_Int :: struct {
	k: Int_Datum,
	v: i32,
}
Set_Entity_Busy :: struct {
	id:   Id,
	busy: bool,
}
Set_Entity_Disabled :: struct {
	id:       Id,
	disabled: bool,
}
Set_Entity_Talk_Script :: struct {
	id:     Id,
	script: []Event,
}
Set_Entity_Trap_Script :: struct {
	id:     Id,
	script: []Event,
}
Set_Entity_State :: struct {
	id:    Id,
	state: State,
}
Set_Entity_Texture :: struct {
	id:      Id,
	texture: Texture_Name,
}
Set_Party_Control :: struct {}
Skip :: struct {
	n: int,
}
Skip_If :: struct {
	n: int,
	d: Bool_Datum,
}
Skip_If_Choice :: struct {
	n: int,
	c: int,
}
Skip_If_Have_Money :: struct {
	n: int,
	m: Money,
}
Start_Encounter :: struct {
	encounter: int,
	paused:    bool,
}
Start_Level :: struct {
	level: Level,
}
Start_Next_Level :: struct {}
Text_Effect :: struct {
	color: rl.Color,
	coord: Pixel_Coord,
	text:  cstring,
}
Toggle_Party_Member :: struct {
	pc_idx: PC,
	join:   bool,
}
Wait_Encounter_R :: struct {}

Event :: union {
	Add_Item,
	Append_Choice,
	Append_Text,
	Battle_Unpause,
	Clear_Text,
	Close_Dialogue,
	Curtain_Down,
	Curtain_Up,
	End,
	Get_Choice,
	Heal_Party,
	Lose_Money,
	Pause_Runner,
	Move_Entity_Here,
	Play_Animation,
	Play_Sound,
	Remove_Entity,
	Set_Boat_Control,
	Set_Bool,
	Set_Int,
	Set_Entity_Busy,
	Set_Entity_Disabled,
	Set_Entity_Talk_Script,
	Set_Entity_Trap_Script,
	Set_Entity_State,
	Set_Entity_Texture,
	Set_Party_Control,
	Skip,
	Skip_If,
	Skip_If_Choice,
	Skip_If_Have_Money,
	Start_Encounter,
	Start_Level,
	Start_Next_Level,
	// Text_Effect,
	Toggle_Party_Member,
	Wait_Encounter_R,
}

process_event :: proc(event: Event) {
	switch event in event {
	case Add_Item:
		add_item(event.item, event.number)
	case Append_Text:
		queue_dialogue(event.text, event.hurry, event.pause)
		runner.state = Wait_Dialogue{}
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
		runner.state = Wait_Transition{}
	case Curtain_Up:
		curtain_up(event.type)
		runner.state = Wait_Transition{}
	case End:
		runner.state = Continue{}
	case Get_Choice:
		dialogue_choice_made = nil
		dialogue_state = Dialogue_Choose{}
		runner.state = Wait_Choice{}
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
		runner.state = Pause {
			countdown = event.duration,
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
	case Wait_Encounter_R:
		runner.state = Wait_Encounter{}
	}
}
