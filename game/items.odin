package game

Item_Name :: enum {
	Potion,
	Super_Potion,
	Antidote,
	Poisonous_Mushroom,
	Sword,
	Chump_Charm,
	Beef_Bracer,
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
	{"Potion", .Potion},
	{"Super Potion", .Super_Potion},
	{"Antidote", .Antidote},
	{"Poisonous Mushroom", .Poisonous_Mushroom},
	{"Sword", Equippable{{offense = 5}, {offense = 10}, .Mainhand}},
	{"Chump Charm", Equippable{{-5, -5, -5, -5, -5, -5}, {-5, -5, -5, -5, -5, -5}, .Accessory}},
	{
		"Beef Bracer",
		Equippable {
			{hitpoints = 10, offense = 2, defense = 2, speed = -1},
			{hitpoints = 10, offense = 5, defense = 5, speed = -5},
			.Sidehand,
		},
	},
	{"Thingamajig", nil},
	{"Doodad", nil},
	{"Deluxe Doodad", nil},
	{"Postcard", nil},
	{"Generic Trinket", nil},
	{"Mundane Tchotchke", nil},
}
