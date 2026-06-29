package game

Skill :: struct {
	name:      string,
	effect:    Effect_Name,
	targeting: Targeting_Type,
	v:         Skill_V, // defined in skill_data.odin
	windup:    int,
	cost:      int,
	cooldown:  int,
	animation: Animation_Name,
	sound:     Sound_Name,
}

Skill_Set :: bit_set[Skill_Name]
