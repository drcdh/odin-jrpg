package game

Selection :: struct {
	origin_idx: int,
	row_idx:    int,
}

selection_row :: proc(s: Selection) -> int {
	return s.row_idx - s.origin_idx
}
