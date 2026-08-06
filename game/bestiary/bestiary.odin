package bestiary

import "core:fmt"
import "core:mem"
import "core:strings"

import rl "vendor:raylib"

import "../../game"

bid: int

texture: rl.RenderTexture

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

	game.init_rl(4)
	game.init_atlases()
	game.init_sprites()

	w, h := f32(game.window_w), f32(game.window_h)

	texture = rl.LoadRenderTexture(game.window_w, game.window_h); defer rl.UnloadRenderTexture(texture)

	bid = 1
	redraw()

	for {
		if rl.IsKeyPressed(.Q) {
			break
		} else if rl.IsKeyPressed(.UP) {
			bid -= 1
			if bid <= 0 {
				bid = game.NUM_BADDY_TEMPLATES - 1
			}
			redraw()
		} else if rl.IsKeyPressed(.DOWN) {
			bid += 1
			if bid >= game.NUM_BADDY_TEMPLATES {
				bid = 1
			}
			redraw()
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawTexturePro(texture.texture, {0, 0, w, -h}, {0, 0, w, -h}, {}, 0, rl.WHITE)
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
	game.tear_down_rl()
}

COORD :: game.Pixel_Coord{480, 160}

redraw :: proc() {
	rl.BeginTextureMode(texture)
	rl.ClearBackground(rl.BLACK)
	bt := game.baddy_templates[game.Baddy_Id(bid)]
	game.draw_sprite(game.create_sprite_state(bt.texture), COORD)
	game.draw_text(0, 0, fmt.ctprintf("% 3d: %s", bid, bt.name))
	for i in 0 ..< game.NUM_STATS {
		game.draw_text(0, f32(i + 1), strings.clone_to_cstring(game.stat_string(bt, game.Stat(i))))
	}
	rl.EndTextureMode()
}
