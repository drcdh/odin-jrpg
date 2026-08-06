package game

import "core:fmt"

BOAT_ID :: 77

board_boat :: proc(boat_id: Id) {
	queue_events(
		[]Event{Set_Entity_Disabled{PLAYER_ID, true}, Set_Entity_Busy{boat_id, false}, Set_Boat_Control{}, End{}},
	)
}

dialogue :: proc(speaker_id: Id, dialogue: string) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Set_Entity_Busy{id = speaker_id, busy = true},
			Set_Entity_Face_Party{id = speaker_id},
			Append_Text{dialogue},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = speaker_id, busy = false},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

egress :: proc(destination: Level) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Curtain_Down{},
			Start_Level{level = destination},
			Curtain_Up{},
			End{},
		},
	)
}

encounter :: proc(encounter: int) {
	set_world_entity_busy(PLAYER_ID, true)
	queue_events(
		[]Event {
			Curtain_Down{.Battle},
			Start_Encounter{encounter = encounter, paused = true},
			Music_Fade_Down{},
			Curtain_Up{.Battle},
			Play_Prev_Music{},
			Music_Fade_Up{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

items_in_a_box :: proc(box_id: Id, items: ..Item_Name) {
	events := make([dynamic]Event)
	defer delete(events)
	append(&events, Set_Entity_Busy{id = PLAYER_ID, busy = true}, Set_Entity_Tag{box_id, .Opened})
	for item in items {
		append(&events, Add_Item{item = item, number = 1})
	}
	append(
		&events,
		Append_Text{fmt.aprintf("Got items: %v", items)}, // FIXME: leak
		Close_Dialogue{},
		Clear_Text{},
		Set_Entity_Busy{id = PLAYER_ID, busy = false},
		End{},
	)
	queue_events(events[:])
}

leave_boat :: proc(boat_id: Id) {
	face := get_world_entity(boat_id).face
	queue_events(
		[]Event {
			Set_Entity_Busy{boat_id, true},
			Move_Entity_Here{PLAYER_ID},
			Set_Entity_Disabled{PLAYER_ID, false},
			Set_Entity_Tag{PLAYER_ID, face},
			Set_Party_Control{},
			End{},
		},
	)
}

monster_in_a_box :: proc(box_id: Id, encounter: int) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Set_Entity_Tag{box_id, .Opened},
			Append_Text{"Monster in a box!"},
			Close_Dialogue{},
			Clear_Text{},
			Curtain_Down{.Battle},
			Start_Encounter{encounter = encounter, paused = true},
			Music_Fade_Down{},
			Curtain_Up{.Battle},
			Play_Prev_Music{},
			Music_Fade_Up{},
			Append_Text{"Didja win?"},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

save_point :: proc(save_point_id: Id, save_point: Save_Point) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text{"Ooh, it's a save point! Save your game?"},
			Append_Choice{"Yeah!"},
			Append_Choice{"Nope."},
			Get_Choice{},
			Clear_Text{},
			Skip_If_Choice{1, 1},
			Save_Game{save_point},
			Close_Dialogue{},
			Set_Entity_Tag{save_point_id, .Inactive},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

text_popup :: proc(dialogue: string) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Append_Text{dialogue},
			Close_Dialogue{},
			Clear_Text{},
			Set_Entity_Busy{id = PLAYER_ID, busy = false},
			End{},
		},
	)
}

warp_to_level :: proc(level: Level) {
	queue_events(
		[]Event {
			Set_Entity_Busy{id = PLAYER_ID, busy = true},
			Play_Sound{sound = .Warp},
			Curtain_Down{},
			Start_Level{level = level},
			Curtain_Up{},
			End{},
		},
	)
}
