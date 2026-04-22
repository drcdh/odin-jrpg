package game

import rl "vendor:raylib"

Animation_Draw :: proc(t: f32, offset: Pixel_Coord)

Animation :: enum {
	Expand_Circle,
}

draw_expanding_circle :: proc(t: f32, offset: Pixel_Coord) {
	rl.DrawCircle(i32(offset.x), i32(offset.y), t*50, rl.Color{150, 50, 70, 255})
}

// Animation_Proc := map[Animation]Animation_Draw {
// 	.Expand_Circle = Animation_Draw {
//
// 	},
// }
