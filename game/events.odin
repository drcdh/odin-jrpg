package game

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
Battle_Effect_Event :: struct {
	actor:  int,
	target: int,
	effect: Effect,
}
Battle_Unpause :: struct {}
Clear_Text :: struct {}
Close_Dialogue :: struct {}
End :: struct {}
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
Move_Entity_Here :: struct {
	id: Id,
}
Play_Animation :: struct {
	animation: Animation_Name,
	offset:    Pixel_Coord,
}
Play_Sound :: struct {
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
	Append_Text,
	Battle_Unpause,
	Clear_Text,
	Close_Dialogue,
	End,
	Pause_Runner,
	Curtain_Down,
	Curtain_Up,
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
	Start_Encounter,
	Start_Level,
	Start_Next_Level,
	// Text_Effect,
	Toggle_Party_Member,
	Wait_Encounter_R,
}
