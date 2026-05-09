package game

import hm "core:container/handle_map"
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

WARP_TO_0 := [?]Event {
	Set_Entity_Busy{id = PLAYER_ID, busy = true},
	Play_Sound{.Warp},
	Curtain_Down{},
	Start_Level{level = .LEVEL_0},
	Curtain_Up{},
	End{},
}

start_level_2 :: proc() {
	add_pc_entity(LEVEL_2_PLAYER_SPAWN, .Down)

	for i := 1; i <= MAP_WIDTH - 3; i += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 100 + i,
				tile = Tile_Coord{i, 1},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 1},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 200 + i,
				tile = Tile_Coord{i, MAP_HEIGHT - 3},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 3},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}
	for j := 3; j <= MAP_HEIGHT - 5; j += 2 {
		_ = hm.add(
			&entities,
			Entity {
				id = 300 + j,
				tile = Tile_Coord{1, j},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 0},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
		_ = hm.add(
			&entities,
			Entity {
				id = 400 + j,
				tile = Tile_Coord{MAP_WIDTH - 3, j},
				speed = 2,
				state = Pacing{route = 2, pause = 1, step = 2},
				v = facing_animation_create(.Dude_World_Left, .Dude_World_Right, .Dude_World_Up, .Dude_World_Down, .Down),
				z = Z_MAX,
			},
		)
	}

	_ = hm.add(
		&entities,
		Entity {
			id = 3,
			ghost = true,
			tile = LEVEL_2_WARP_SPAWN,
			n = "warp",
			trap = WARP_TO_0[:],
			v = animation_create(.Warp),
		},
	)
}
