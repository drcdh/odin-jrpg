package game

Item_Name :: enum {
	Potion,
	Super_Potion,
	Antidote,
	Poisonous_Mushroom,
	Sword,
	Thingamajig,
	Doodad,
	Deluxe_Doodad,
	Postcard,
	Generic_Trinket,
	Mundane_Tchotchke,
	None,
}

Item :: struct {
	name: string,
	data: Item_Variant,
}

Item_Variant :: union {
	Consumable,
	Equippable,
}

Consumable :: Skill_Name

Equippable :: struct {
	stats_add: Stats,
	stats_mul: Stats,
	slot:      Equipment_Slot,
}

NUM_ITEMS :: len(Item_Name) - 1

items := [NUM_ITEMS]Item {
	{"Potion", .Heal_50},
	{"Super Potion", .Heal_500},
	{"Antidote", .Remove_Poison},
	{"Poisonous Mushroom", .Add_Poison},
	{"Sword", Equippable{{offense = 5}, {offense = 10}, .Mainhand}},
	{"Thingamajig", nil},
	{"Doodad", nil},
	{"Deluxe Doodad", nil},
	{"Postcard", nil},
	{"Generic Trinket", nil},
	{"Mundane Tchotchke", nil},
}
