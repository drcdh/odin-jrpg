package game

Baddy_Visual :: union {
	Animation_Name,
	Texture_Name,
}

Baddy_Template :: struct {
	name:        cstring,
	using stats: Stats,
	texture:     Baddy_Visual,
	turn:        Turn_Proc,
}

new_baddy :: proc(template: Baddy_Template) -> ^Character {
	baddy := new(Character)
	baddy.name = template.name
	baddy.hitpoints = template.stats.max_hitpoints
	baddy.stats = template.stats
	return baddy
}
