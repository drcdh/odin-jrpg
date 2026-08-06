package game

Baddy_Template :: struct {
	name:        cstring,
	skills:      Skill_Set,
	using stats: Stats,
	texture:     Sprite_Name,
	turn:        Turn_Proc,
}

new_baddy :: proc(template: Baddy_Template) -> ^Character {
	baddy := new(Character)
	baddy.name = template.name
	baddy.hitpoints = template.stats.max_hitpoints
	baddy.skills = Skill_Set_C {
		skills = template.skills,
	}
	baddy.stats = template.stats
	return baddy
}
