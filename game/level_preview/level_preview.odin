#+vet !unused
package level_preview

import "core:fmt"
import rl "vendor:raylib"

import "../../game"

main :: proc() {
	game.init_rl(3)

	tile_size := game.tile_size
	tile_size_i := i32(tile_size)

	layers := 2
	w := 20*tile_size_i
	h := 20*tile_size_i
	wf := 20*tile_size
	hf := 20*tile_size

	rl.SetWindowSize(w, h)

	highlight_impassible : bool
	texture := rl.LoadRenderTexture(w, h)
	pTexture := rl.LoadRenderTexture(w, h)

	rl.BeginTextureMode(texture)
	for l in 0..<layers {
		for j in 0..<20 {
			for i in 0..<20 {
				t := game.level_1_map[l][j][i] - 1
				pos := game.tile_to_pixel(game.Tile_Coord{i, j})
				game.draw_tile(l, t, pos)
			}
		}
	}
	rl.EndTextureMode()

	rl.BeginTextureMode(pTexture)
	for j in 0..<20 {
		for i in 0..<20 {
				p := game.LEVEL_1_PASSABLE[j][i]
				if !p {
					i := i32(i)
					j := i32(j)
					// rl.DrawCircle(i*tile_size_i+tile_size_i/2, j*tile_size_i+tile_size_i/2, tile_size/2, rl.PURPLE)
					rl.DrawRectangle(i*tile_size_i, j*tile_size_i, tile_size_i, tile_size_i, rl.PURPLE)
				}
			}
		}
	rl.EndTextureMode()

	for {
		if rl.IsKeyPressed(.Q) { break }
		if rl.IsKeyPressed(.P) { highlight_impassible = !highlight_impassible }
		rl.BeginDrawing()
		rl.DrawTexturePro(texture.texture, {0, 0, wf, -hf}, {0, 0, wf, hf}, {}, 0, rl.WHITE)
		if highlight_impassible {
			rl.DrawTexturePro(pTexture.texture, {0, 0, wf, -hf}, {0, 0, wf, hf}, {}, 0, {0, 0, 0, 150})
		}
		rl.EndDrawing()
	}

	rl.UnloadRenderTexture(texture)
	rl.UnloadRenderTexture(pTexture)

	game.tear_down_rl()
}
