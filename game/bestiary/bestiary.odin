#+vet !unused
package bestiary

import "core:fmt"
import "core:mem"
import "core:strings"

import rl "vendor:raylib"

import "../../game"

bid: int

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\bid", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\bid", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	game.init_rl(3)

	bid = 1
	draw()

	for {
		if rl.IsKeyPressed(.Q) {
			break
		} else if rl.IsKeyPressed(.UP) {
			bid -= 1
			if bid <= 0 {
				bid = game.NUM_BADDY_TEMPLATES - 1
			}
		} else if rl.IsKeyPressed(.DOWN) {
			bid += 1
			if bid >= game.NUM_BADDY_TEMPLATES {
				bid = 1
			}
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		draw()
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
	game.tear_down_rl()
}

coord :: game.Pixel_Coord{400, 100}

draw :: proc() {
	bt := game.baddy_templates[game.Baddy_Id(bid)]
	switch t in bt.texture {
	case game.Texture_Name:
		game.draw_texture(t, coord, rl.WHITE)
	case game.Animation_Name:
		game.draw_texture(game.atlas_animations[t].first_frame, coord, rl.WHITE)
	}
	draw_text(0, 0, fmt.caprintf("% 3d: %s", bid, bt.name))
	for i in 0 ..< game.NUM_STATS {
		draw_text(0, 0, strings.clone_to_cstring(game.stat_string(bt, game.Stat(i)), context.temp_allocator))
	}
}
