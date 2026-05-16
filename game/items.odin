package game

Item :: enum {
	Potion,
	Super_Potion,
	Antidote,
	Poisonous_Mushroom,
}

Item_Data :: struct {
	name:      string,
	targeting: Targeting_Type,
	effect:    Effect_Name,
	power:     int,
}

item_data := [len(Item)]Item_Data {
	{"Potion", .One_Ally, .Heal_Hp_Constant, 50},
	{"Super Potion", .One_Ally, .Heal_Hp_Constant, 500},
	{"Antidote", .One_Ally, .Remove_Poison, 100},
	{"Poisonous Mushroom", .One_Ally, .Add_Poison, 100},
}
