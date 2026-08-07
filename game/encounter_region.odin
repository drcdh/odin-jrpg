package game

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

Encounter_Region_Rect :: struct {
	level:  Level,
	rect:   Rect,
	region: Encounter_Region,
}

try_random_encounter :: proc(level: Level, tile: Tile_Coord) {
	region := get_encounter_region(level, tile)
	// fmt.printfln("inside encounter region %v", region)
	if enc_idx, ok := get_encounter(region).?; ok {
		fmt.printfln("starting random encounter %d", enc_idx)
		encounter(enc_idx)
	} else {
		// fmt.println("no random encounter, this time...")
	}
}

get_encounter_region :: proc(level: Level, tile: Tile_Coord) -> Encounter_Region {
	for err in encounter_region_rects {
		if level == err.level && tile_in_rect(tile, err.rect) {
			return err.region
		}
	}
	return .None
}

get_encounter :: proc(region: Encounter_Region) -> (enc: Maybe(int)) {
	switch region {
	case .None:
	case .Blah:
		if rand.int_max(4) == 0 {
			encs := [?]int{0}
			enc = rand.choice(encs[:])
		} else {
			enc = nil
		}
	}
	return
}

tile_in_rect :: proc(tile: Tile_Coord, rect: Rect) -> bool {
	return rl.CheckCollisionPointRec({f32(tile.x), f32(tile.y)}, rect)
}
