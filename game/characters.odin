package game

import "core:strings"

Character :: struct {
	name:            cstring,
	using equipment: Equipment,
	using stats:     Stats,
	using status:    Status,
}

Status :: struct {
	poison: bool,
	zombie: bool,
}

get_status_cstring :: proc(status: Status) -> cstring {
	s := ""
	if status.poison {
		s = strings.concatenate({s, "P"}, context.temp_allocator)
	}
	if status.zombie {
		s = strings.concatenate({s, "Z"}, context.temp_allocator)
	}
	return strings.clone_to_cstring(s)
}
