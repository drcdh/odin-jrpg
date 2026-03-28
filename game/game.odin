package game

entities: [dynamic]Entity
m: Map

draw_level :: proc() {
	draw_map(m)
	for e in entities {
		draw_entity(e)
	}
}

update_level :: proc(dt: f32) {
	for &e in entities {
		update_entity(dt, &e)
	}
}
