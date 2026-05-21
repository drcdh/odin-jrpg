package game

Item_Name :: enum {
	Potion,
	Super_Potion,
	Antidote,
	Poisonous_Mushroom,
	Sword,
	Thingamajig,
}

Item :: struct {
	name: string,
	data: Item_Variant,
}

Item_Variant :: union {
	Consumable,
	Equipment,
}

Consumable :: Skill_Name

Equipment :: struct {
	power: int,
	// slot: Equipment_Slot,
}

items := [len(Item_Name)]Item {
	{"Potion", .Heal_50},
	{"Super Potion", .Heal_500},
	{"Antidote", .Remove_Poison},
	{"Poisonous Mushroom", .Add_Poison},
	{"Sword", Equipment{10}},
	{"Thingamajig", nil},
}
