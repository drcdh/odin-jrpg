// #+vet !unused
package level_preview

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

import "../../game"

pTexture: rl.RenderTexture
rTexture: rl.RenderTexture
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

	highlight_encounter_regions: bool
	highlight_impassible: bool

	for {
		if rl.IsKeyPressed(.Q) {break}
		if rl.IsKeyPressed(.P) {
			highlight_impassible = !highlight_impassible
			fmt.printfln("toggle highlight_impassible %v", highlight_impassible)
		}
		if rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.RIGHT) {
			li += 1
			if li >= len(game.Level) {li = 0}
			load(game.Level(li))
		} else if rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.LEFT) {
			li -= 1
			if li < 0 {li = len(game.Level) - 1}
			load(game.Level(li))
		}
		if rl.IsKeyPressed(.E) || rl.IsKeyPressed(.R) {
			highlight_encounter_regions = !highlight_encounter_regions
			fmt.printfln("toggle highlight_encounter_regions %v", highlight_encounter_regions)
		}

		rl.BeginDrawing()
		game.draw_map()
		if highlight_encounter_regions {
			rl.DrawTexturePro(rTexture.texture, {0, 0, wf, -hf}, {0, 0, wf, hf}, {}, 0, {255, 255, 255, 100})
		}
		if highlight_impassible {
			rl.DrawTexturePro(pTexture.texture, {0, 0, wf, -hf}, {0, 0, wf, hf}, {}, 0, {255, 255, 255, 150})
		}
		rl.EndDrawing()
	}

	rl.UnloadRenderTexture(pTexture)
	rl.UnloadRenderTexture(rTexture)

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
	rl.UnloadRenderTexture(rTexture)
	rTexture = rl.LoadRenderTexture(w, h)
	rl.SetWindowSize(w, h)
	render_passable()
	render_encounter_regions()
}

render_passable :: proc() {
	rl.BeginTextureMode(pTexture)
	rl.ClearBackground({})
	for j in 0 ..< game.map_dim.y {
		for i in 0 ..< game.map_dim.x {
			p: u8
			switch game.current_level {
			case game.Level.Level_0:
				p = game.LEVEL_0_PASSABLE[j][i]
			case game.Level.Level_1:
				p = game.LEVEL_1_PASSABLE[j][i]
			case game.Level.Level_2:
				p = game.LEVEL_2_PASSABLE[j][i]
			case game.Level.Level_Overworld:
				p = game.LEVEL_OVERWORLD_PASSABLE[j][i]
			case game.Level.Level_Cave:
				p = game.LEVEL_CAVE_PASSABLE[j][i]
			}
			if p == 0 {continue}
			c: rl.Color
			if p == 1 {c = rl.RED} else if p == 2 {c = rl.BLUE} else if p == 3 {c = rl.PURPLE}
			i := i32(i)
			j := i32(j)
			rl.DrawRectangle(i * tile_size_i, j * tile_size_i, tile_size_i, tile_size_i, c)
		}
	}
	rl.EndTextureMode()
}

render_encounter_regions :: proc() {
	rl.BeginTextureMode(rTexture)
	rl.ClearBackground({})
	colors := make(map[game.Encounter_Region]rl.Color)
	defer delete(colors)
	for err in game.encounter_region_rects {
		if err.level != game.current_level {continue}
		region := err.region
		if !(region in colors) {
			colors[region] = {u8(rand.int_max(256)), u8(rand.int_max(256)), u8(rand.int_max(256)), 255}
		}
		rl.DrawRectangleV(
			{err.rect.x * tile_size, err.rect.y * tile_size},
			{err.rect.width * tile_size, err.rect.height * tile_size},
			colors[region],
		)
	}
	rl.EndTextureMode()
}
