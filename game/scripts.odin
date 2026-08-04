package game

import "core:fmt"

items_in_a_box :: proc(items: ..Item_Name) {
	events := make([dynamic]Event)
	defer delete(events)
	append(&events, Set_Entity_Busy{id = PLAYER_ID, busy = true})
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
