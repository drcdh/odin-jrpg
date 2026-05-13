// #+vet !unused
package level_preview

import "core:fmt"
import rl "vendor:raylib"

import "../../game"

pTexture: rl.RenderTexture
tile_size: f32
tile_size_i: i32
w: i32
h: i32
wf: f32
hf: f32

main :: proc() {
	game.init_rl(1)

	tile_size = game.tile_size
	tile_size_i = i32(tile_size)

	li := 0

	load(game.Level(li))

	highlight_impassible: bool

	for {
		if rl.IsKeyPressed(.Q) {break}
		if rl.IsKeyPressed(.P) {highlight_impassible = !highlight_impassible}
		if rl.IsKeyPressed(.DOWN) {
			li += 1
			if li >= len(game.Level) {li = 0}
			load(game.Level(li))
		} else if rl.IsKeyPressed(.UP) {
			li -= 1
			if li < 0 {li = len(game.Level) - 1}
			load(game.Level(li))
		}
		rl.BeginDrawing()
		game.draw_map()
		if highlight_impassible {
			rl.DrawTexturePro(pTexture.texture, {0, 0, wf, -hf}, {0, 0, wf, hf}, {}, 0, {0, 0, 0, 150})
		}
		rl.EndDrawing()
	}

	rl.UnloadRenderTexture(pTexture)

	game.tear_down_rl()
}

load :: proc(l: game.Level) {
	fmt.println("Loading", l)
	game.start_level(l)
	wf = f32(game.map_dim.x) * tile_size
	hf = f32(game.map_dim.y) * tile_size
	w = i32(wf)
	h = i32(hf)
	rl.UnloadRenderTexture(pTexture)
	pTexture = rl.LoadRenderTexture(w, h)
	rl.SetWindowSize(w, h)
	render_passable()
}

render_passable :: proc() {
	rl.BeginTextureMode(pTexture)
	rl.ClearBackground({})
	for j in 0 ..< game.map_dim.y {
		for i in 0 ..< game.map_dim.x {
			free: bool
			switch game.current_level {
			case game.Level.LEVEL_0:
				free = game.LEVEL_0_PASSABLE[j][i]
			case game.Level.LEVEL_1:
				free = game.LEVEL_1_PASSABLE[j][i]
			case game.Level.LEVEL_2:
				free = game.LEVEL_2_PASSABLE[j][i]
			case game.Level.LEVEL_OVERWORLD:
				free = game.LEVEL_OVERWORLD_PASSABLE[j][i]
			}
			if !free {
				i := i32(i)
				j := i32(j)
				// rl.DrawCircle(i*tile_size_i+tile_size_i/2, j*tile_size_i+tile_size_i/2, tile_size/2, rl.PURPLE)
				rl.DrawRectangle(i * tile_size_i, j * tile_size_i, tile_size_i, tile_size_i, rl.PURPLE)
			}
		}
	}
	rl.EndTextureMode()
}
