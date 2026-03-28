package main

import "core:os"

import "game"

main :: proc() {
	defer os.exit(game.start(os.args))
}
