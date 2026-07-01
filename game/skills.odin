package game

Skill :: struct {
	name:      string,
	effect:    Effect,
	targeting: Targeting_Type,
	windup:    int,
	cost:      int,
	cooldown:  int,
	animation: Animation_Name,
	sound:     Sound_Name,
}

Skill_Set :: bit_set[Skill_Name]
