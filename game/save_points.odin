package game

Save_Point :: enum {
	Level_0,
	Level_2,
}

start_save_point :: proc(save_point: Save_Point) {
	switch save_point {
	case .Level_0:
		queue_events([]Event{Start_Level{level = .LEVEL_0}, Curtain_Up{}, End{}})
	case .Level_2:
		queue_events([]Event{Start_Level{level = .LEVEL_2}, Curtain_Up{}, End{}})
	}
}
