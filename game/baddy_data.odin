package game

Baddy_Id :: enum {
	None,
	Mouse_Sized_Rat,
	Rat_Sized_Mouse,
}

baddy_templates := [?]Baddy_Template{
	Baddy_Template {},
	Baddy_Template {
		name = "Mouse-Sized Rat",
		stats = Stats{hitpoints = 1, offense = 1, defense = 1},
		texture = .Mouse_Sized_Rat,
		turn = ATTACK_RANDOM_OPPONENT,
	},
	Baddy_Template {
		name = "Rat-Sized Mouse",
		stats = Stats{hitpoints = 3, offense = 3, defense = 2},
		texture = .Rat_Sized_Mouse,
		turn = ATTACK_RANDOM_OPPONENT,
	},
}

