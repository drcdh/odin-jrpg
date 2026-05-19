package game

Item :: enum {
	Potion,
	Super_Potion,
	Antidote,
	Poisonous_Mushroom,
	Sword,
	Thingamajig,
}

Item_Data :: struct {
	name: string,
	data: Item_Variant,
}

Item_Variant :: union {
	Consumable,
	Equipment,
}

Consumable :: struct {
	targeting: Targeting_Type,
	effect:    Effect_Name,
	power:     int,
}

Equipment :: struct {
	power: int,
	// slot: Equipment_Slot,
}

item_data := [len(Item)]Item_Data {
	{"Potion", Consumable{.One_Ally, .Heal_Hp_Constant, 50}},
	{"Super Potion", Consumable{.One_Ally, .Heal_Hp_Constant, 500}},
	{"Antidote", Consumable{.One_Ally, .Remove_Poison, 100}},
	{"Poisonous Mushroom", Consumable{.One_Ally, .Add_Poison, 100}},
	{"Sword", Equipment{10}},
	{name = "Thingamajig"},
}
