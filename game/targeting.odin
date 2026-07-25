package game

Target_Selection :: union {
	Target_One_Ally,
	Target_One_Baddy,
	Target_All_Allies,
	Target_All_Baddies,
	Target_All_Combatants,
}
Target_One_Ally :: struct {
	i: int,
}
Target_One_Baddy :: struct {
	i: int,
}
Target_All_Baddies :: struct {
	prev: int,
}
Target_All_Allies :: struct {
	prev: int,
}
Target_One_Combatant :: struct {
	i: int,
}
Target_All_Combatants :: struct {}

Target_Type :: enum {
	One_Opponent,
	Some_Opponents,
	All_Opponents,
	One_Ally,
	Some_Allies,
	All_Allies,
	One_Combatant,
	All_Combatants,
}
