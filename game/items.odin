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

Consumable :: Skill
// Consumable :: struct {
// 	targeting: Targeting_Type,
// 	effect:    Effect_Name,
// 	power:     int,
// }

Equipment :: struct {
	power: int,
	// slot: Equipment_Slot,
}

item_data := [len(Item)]Item_Data {
	{"Potion", .Heal_50},
	{"Super Potion", .Heal_500},
	{"Antidote", .Remove_Poison},
	{"Poisonous Mushroom", .Add_Poison},
	{"Sword", Equipment{10}},
	{"Thingamajig", nil},
}
