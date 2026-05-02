package main

import "game"

main :: proc() {
	game.init()
	for game.running {
		game.draw()
		game.update()
	}
	game.tear_down()
}
