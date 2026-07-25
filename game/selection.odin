package game

Selection :: struct {
	origin_idx: int,
	row_idx:    int,
}

selection_row :: proc(s: Selection) -> int {
	return s.row_idx - s.origin_idx
}

selection_row_f :: proc(s: Selection) -> f32 {
	return f32(selection_row(s))
}
