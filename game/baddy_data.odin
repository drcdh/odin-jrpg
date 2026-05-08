package game

baddy_templates := [?]Baddy_Template {
	Baddy_Template{},
	Baddy_Template {
		name = "Mouse-Sized Rat",
		hitpoints = 5,
		offense = 2,
		defense = 2,
		texture = .Mouse_Sized_Rat,
		turn = ATTACK_RANDOM_OPPONENT,
	},
	Baddy_Template {
		name = "Rat-Sized Mouse",
		hitpoints = 15,
		offense = 5,
		defense = 5,
		texture = .Rat_Sized_Mouse,
		turn = ATTACK_RANDOM_OPPONENT,
	},
	Baddy_Template {
		name = "Malicious Mushroom",
		hitpoints = 6,
		offense = 3,
		defense = 2,
		texture = .Mushroom,
		turn = ATTACK_RANDOM_OPPONENT,
	},
	Baddy_Template {
		name = "Generic Goblin",
		hitpoints = 12,
		offense = 10,
		defense = 10,
		texture = .Goblin_Club,
		turn = ATTACK_RANDOM_OPPONENT,
	},
	Baddy_Template {
		name = "Generic Goblin",
		hitpoints = 12,
		offense = 10,
		defense = 10,
		texture = .Goblin_Knife,
		turn = ATTACK_RANDOM_OPPONENT,
	},
	Baddy_Template {
		name = "Ghost",
		hitpoints = 1,
		offense = 4,
		defense = 100,
		texture = .Ghost,
		turn = ATTACK_RANDOM_OPPONENT,
	},
}

Baddy_Id :: enum {
	None,
	Mouse_Sized_Rat,
	Rat_Sized_Mouse,
	Malicious_Mushroom,
	Generic_Goblin_1,
	Generic_Goblin_2,
	Ghost,
}
