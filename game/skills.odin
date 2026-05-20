package game

Skill :: enum {
	Attack,
	Fire_10_25,
	Heal_50,
	Heal_500,
	Remove_Poison,
	Add_Poison,
}

Skill_Data :: struct {
	effect:    Effect_Name,
	targeting: Targeting_Type,
	power:     int,
	time:      int,
	animation: Animation_Name,
	sound:     Sound_Name,
}

skill_data := [len(Skill)]Skill_Data {
	{.Attack, .One_Opponent, 0, 10, .Whack, .Whack},
	{.Fire, .Some_Opponents, 10, 25, nil, nil},
	{.Heal_Hp_Constant, .One_Ally, 50, 0, nil, .Warp},
	{.Heal_Hp_Constant, .One_Ally, 500, 0, nil, .Warp},
	{.Remove_Poison, .One_Ally, 100, 0, nil, .Warp},
	{.Add_Poison, .One_Ally, 100, 0, nil, .Warp},
}
