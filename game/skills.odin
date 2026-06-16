package game

Skill :: struct {
	name:      string,
	effect:    Effect_Name,
	targeting: Targeting_Type,
	power:     int,
	time:      int,
	animation: Animation_Name,
	sound:     Sound_Name,
}
