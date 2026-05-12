package game

Item :: enum {
	Potion,
	Super_Potion,
}

Item_Data :: struct {
	name: string,
	targeting: Targeting_Type,
	effect: Effect_F,
	power: int,
}

item_data := [len(Item)]Item_Data{
	{"Potion", .One_Combatant, effect_heal_hp_constant, 50},
	{"Super Potion", .One_Combatant, effect_heal_hp_constant, 500},
}
