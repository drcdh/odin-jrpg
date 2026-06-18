package game

Skill :: struct {
	name:      string,
	effect:    Effect_Name,
	targeting: Targeting_Type,
	power:     int,
	windup:    int,
	cost:      int,
	cooldown:  int,
	animation: Animation_Name,
	sound:     Sound_Name,
}

Skill_Set :: bit_set[Skill_Name]
