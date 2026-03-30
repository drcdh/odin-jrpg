package game

hack := true

player_control :: proc(_: f32, p: ^Entity) {
	if !p.k.moving {
		input := get_direction_input()
		if (input.x != 0 || input.y != 0) {
			try_set_destination(&p.k, p.k.tile + input)
		} else {
			if get_input(.ENTER) {
				if hack {
					//fixme HACK
					set_entity_state(DUDE_ID, Talking{tree = 1})
					hack = false
				}
			}
		}
	}
}
