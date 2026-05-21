package game

Skill_Name :: enum {
	Attack,
	Fire_10_25,
	Heal_50,
	Heal_500,
	Remove_Poison,
	Add_Poison,
}

Skill :: struct {
	effect:    Effect_Name,
	targeting: Targeting_Type,
	power:     int,
	time:      int,
	animation: Animation_Name,
	sound:     Sound_Name,
}

skills := [len(Skill_Name)]Skill {
	{.Attack, .One_Opponent, 0, 10, .Whack, .Whack},
	{.Fire, .Some_Opponents, 10, 25, .Small_Flame, nil},
	{.Heal_Hp_Constant, .One_Ally, 50, 0, nil, .Warp},
	{.Heal_Hp_Constant, .One_Ally, 500, 0, nil, .Warp},
	{.Remove_Poison, .One_Ally, 100, 0, nil, .Warp},
	{.Add_Poison, .One_Ally, 100, 0, nil, .Warp},
}
