package game

Item :: enum {
	Potion,
	Super_Potion,
	Antidote,
	Poisonous_Mushroom,
}

Item_Data :: struct {
	name: string,
	targeting: Targeting_Type,
	effect: Effect_F,
	power: int,
}

item_data := [len(Item)]Item_Data{
	{"Potion", .One_Ally, effect_heal_hp_constant, 50},
	{"Super Potion", .One_Ally, effect_heal_hp_constant, 500},
	{"Antidote", .One_Ally, effect_remove_poison_constant, 100},
	{"Poisonous Mushroom", .One_Ally, effect_add_poison_constant, 100},
}
