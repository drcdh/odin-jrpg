package game

Baddy_Visual :: union {
	Animation_Name,
	Texture_Name,
}

Baddy_Template :: struct {
	name:    cstring,
	using stats:   Stats,
	texture: Baddy_Visual,
	turn:    Turn_Proc,
}
