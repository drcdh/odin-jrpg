package sprite_preview

import hm "core:container/handle_map"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"
import rl "vendor:raylib"

import "../../game"

change_pose :: proc(state: ^game.Sprite_State, ds: int, n: int) {
	if v, ok := state.variant.(game._Sprite_State_Tagged); ok {
		game.set_sprite_tag(state, game.Sprite_Tag((int(v.tag) + ds) %% n))
	}
}

main :: proc() {
	game.zoom = 10

	rl.InitWindow(640, 640, "Sprite Preview")
	rl.SetTargetFPS(60)

	fmt.println()

	i: int
	tag_idx: int
	state := game.create_sprite_state(game.Sprite_Name(i))

	for {
		dt := rl.GetFrameTime()

		if rl.IsKeyPressed(.Q) {
			break
		} else if rl.IsKeyPressed(.DOWN) {
			if mp, ok := game.sprite_metadata[game.Sprite_Name(i)].metadata.(game._Sprite_Metadata_Tagged); ok {
				tag_idx = (tag_idx + 1) %% len(mp.tags)
				game.set_sprite_tag(&state, mp.tags[tag_idx])
			}
		} else if rl.IsKeyPressed(.UP) {
			if mp, ok := game.sprite_metadata[game.Sprite_Name(i)].metadata.(game._Sprite_Metadata_Tagged); ok {
				tag_idx = (tag_idx - 1) %% len(mp.tags)
				game.set_sprite_tag(&state, mp.tags[tag_idx])
			}
		} else if rl.IsKeyPressed(.LEFT) {
			i = (i - 1) %% len(game.Sprite_Name)
			state = game.create_sprite_state(game.Sprite_Name(i))
		} else if rl.IsKeyPressed(.RIGHT) {
			i = (i + 1) %% len(game.Sprite_Name)
			state = game.create_sprite_state(game.Sprite_Name(i))
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		game.draw_sprite(state, {})
		rl.DrawText(fmt.ctprintf("%#v", state), 320, 16, 24, rl.WHITE)
		rl.EndDrawing()

		game.update_sprite(dt, &state)

		free_all(context.temp_allocator)
	}
}
