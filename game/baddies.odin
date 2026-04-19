package game

new_mouse_sized_rat :: proc() -> NPC_Combatant { return NPC_Combatant{
	character = Character{
	stats = Stats{hitpoints=1, offense=1, defense=1},
	name = "Mouse-Sized Rat",
},
	turn = proc() -> Battle_Action {
		return BA_ATTACK
	},
}}

new_rat_sized_mouse :: proc() -> NPC_Combatant { return NPC_Combatant{
	character = Character{
	stats = Stats{hitpoints=3, offense=3, defense=2},
	name = "Rat-Sized Mouse",
	},
	turn = proc() -> Battle_Action {
		return BA_ATTACK
	},
}}
