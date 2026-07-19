package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Shop :: struct {
	inventory: []Item_Name,
}

demo_shop := Shop {
	inventory = {.Potion},
}

Shop_UI_Data :: struct {
	top:        int,
	character:  int,
	slot:       int,
	inv_origin: int,
	inv_row:    int,
}

Shop_UI_State :: enum {
	Inactive,
	Top,
	Buy,
	Sell,
	Swap_Character,
	Swap_Slot,
	Swap_Buy,
}

Shop_Pane :: enum {
	Top,
	Inventory,
	Party,
	Equipment,
	Stats,
}

SHOP_NUM_TEXTURES :: len(Shop_Pane)

Shop_Menu_Data :: struct {
	shop:     ^Shop,
	stale:    [SHOP_NUM_TEXTURES]bool,
	textures: [SHOP_NUM_TEXTURES]rl.RenderTexture,
	ui_data:  Shop_UI_Data,
	ui_state: Shop_UI_State,
}

PANE_ORIGIN := [?]Tile_Coord{{0, 0}, {0, 2}, {11, 2}, {11, 2}, {11, 2}}

PANE_DIM := [?][2]int{{11, 2}, {11, 12}, {5, 12}, {5, 12}, {5, 12}}

SHOP_INVENTORY_ROWS :: 10

shop_menu_data: Shop_Menu_Data

shop_load :: proc() {
	for pane in Shop_Pane {
		dim := PANE_DIM[pane]
		shop_menu_data.textures[pane] = rl.LoadRenderTexture(i32(dim.x) * i32(tile_size), i32(dim.y) * i32(tile_size))
	}
}

shop_unload :: proc() {
	for t in shop_menu_data.textures {
		rl.UnloadRenderTexture(t)
	}
}

shop_enter :: proc(shop: ^Shop) {
	shop_menu_data.shop = shop
	shop_menu_data.ui_data = Shop_UI_Data{}
	shop_menu_data.ui_state = .Top

	for pane in Shop_Pane {
		shop_redraw_texture(pane)
	}
}

shop_exit :: proc() {
	shop_menu_data.shop = nil
	shop_menu_data.ui_state = .Inactive
}

shop_menu_active :: proc() -> bool {
	return shop_menu_data.ui_state != .Inactive
}

shop_draw :: proc() {
	for &stale, i in shop_menu_data.stale {
		if stale {
			shop_redraw_texture(Shop_Pane(i))
			stale = false
		}
	}
	switch shop_menu_data.ui_state {
	case .Inactive:
	case .Top:
		shop_draw_panes(.Top, .Inventory, .Party)
	case .Buy:
		shop_draw_panes(.Top, .Inventory, .Party)
	case .Sell:
		shop_draw_panes(.Top, .Inventory, .Party)
	case .Swap_Character:
		shop_draw_panes(.Top, .Inventory, .Party)
	case .Swap_Slot:
		shop_draw_panes(.Top, .Inventory, .Equipment)
	case .Swap_Buy:
		shop_draw_panes(.Top, .Inventory, .Stats)
	}
	shop_draw_icons()
}

shop_draw_icons :: proc() {
}

shop_redraw_texture :: proc(pane: Shop_Pane) {
	fmt.printfln("Redrawing texture for %w", pane)
	rl.BeginTextureMode(shop_menu_data.textures[pane])
	draw_menu(PANE_DIM[pane])
	switch pane {
	case .Top:
		draw_text(1, .75, strings.clone_to_cstring("Buy  Sell  Swap", allocator = context.temp_allocator))
	case .Inventory:
		shop_draw_inventory()
	case .Party:
		for p in 0 ..< party_size() {
			if pc_idx, ok := get_party_member(p).?; ok {
				origin_tile: Tile_Coord = {1, 1} + {p % 2, int(p / 2)}
				origin := tile_to_pixel(origin_tile)
				draw_texture(pc_idle_texture[pc_idx], origin)
			}
		}
	case .Equipment:
		party_idx := shop_menu_data.ui_data.character
		if pc_idx, ok := get_party_member(party_idx).?; ok {
			pc := get_pc(pc_idx)
			for slot_idx in 0 ..< NUM_EQUIPMENT_SLOTS {
				draw_text(
					1,
					1 + f32(slot_idx),
					strings.clone_to_cstring(equipment_string(pc^, Equipment_Slot(slot_idx)), context.temp_allocator),
				)
			}
		}
	case .Stats:
		party_idx := shop_menu_data.ui_data.character
		if pc_idx, ok := get_party_member(party_idx).?; ok {
			pc := get_pc(pc_idx)
			for s in Stat {
				draw_text(2, 3 + f32(s), strings.clone_to_cstring(stat_string(pc^, s), context.temp_allocator))
			}
		}
	}
	rl.EndTextureMode()
}

shop_draw_pane :: proc(pane: Shop_Pane) {
	origin_tile := PANE_ORIGIN[pane]
	origin := tile_to_pixel(origin_tile)
	texture := shop_menu_data.textures[pane].texture
	w := f32(texture.width)
	h := f32(texture.height)
	dest := rl.Rectangle{origin.x, origin.y, w, -h}
	rl.DrawTexturePro(texture, {0, 0, w, -h}, dest, {}, 0, rl.WHITE)
}

shop_draw_panes :: proc(panes: ..Shop_Pane) {
	for pane in panes {
		shop_draw_pane(pane)
	}
}

shop_draw_inventory :: proc() {
	for r in 0 ..< SHOP_INVENTORY_ROWS {
		if r >= len(shop_menu_data.shop.inventory) {break}
		draw_text(
			1,
			1 + f32(r),
			fmt.ctprint(items[shop_menu_data.shop.inventory[r + shop_menu_data.ui_data.inv_origin]].name),
		)
		// TODO: price
		// TODO: quantity, maybe
	}
}

shop_update :: proc() {
	switch shop_menu_data.ui_state {
	case .Inactive:
	case .Top:
		if get_input(.CANCEL) {
			shop_exit()
		} else if get_input(.ENTER) {
			switch shop_menu_data.ui_data.top {
			case 0:
				shop_menu_data.ui_state = .Buy
			case 1:
				shop_menu_data.ui_state = .Sell
			case 2:
				shop_menu_data.ui_state = .Swap_Character
			}
		} else if dx, ok := get_x_input().?; ok {
			shop_menu_data.ui_data.top = grid_change(shop_menu_data.ui_data.top, dx, 0, 3, 1)
		}
	case .Buy:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Top
		} else if get_input(.ENTER) {
			shop_buy_item()
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.inv_row, shop_menu_data.ui_data.inv_origin = shift_windowed_selection(
				dy,
				shop_menu_data.ui_data.inv_row,
				shop_menu_data.ui_data.inv_origin,
				SHOP_INVENTORY_ROWS,
				len(shop_menu_data.shop.inventory),
			)
		}
	case .Sell:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Top
		} else if get_input(.ENTER) {
			sell_item()
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.inv_row, shop_menu_data.ui_data.inv_origin = shift_windowed_selection(
				dy,
				shop_menu_data.ui_data.inv_row,
				shop_menu_data.ui_data.inv_origin,
				SHOP_INVENTORY_ROWS,
				len(inventory_order),
			)
		}
	case .Swap_Character:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Top
		} else if get_input(.ENTER) {
			shop_menu_data.ui_state = .Swap_Slot
		} else {
			m := get_menu_input()
			shop_menu_data.ui_data.character = grid_change(shop_menu_data.ui_data.character, m.x, m.y, 2, 3)
		}
	case .Swap_Slot:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Swap_Character
		} else if get_input(.ENTER) {
			shop_menu_data.ui_state = .Swap_Buy
		} else if dx, ok := get_x_input().?; ok {
			shop_menu_data.ui_data.slot = grid_change(shop_menu_data.ui_data.slot, dx, 0, NUM_EQUIPMENT_SLOTS, 1)
		}
	case .Swap_Buy:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Swap_Slot
		} else if get_input(.ENTER) {
			shop_buy_item()
			// TODO: equip immediately
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.inv_row, shop_menu_data.ui_data.inv_origin = shift_windowed_selection(
				dy,
				shop_menu_data.ui_data.inv_row,
				shop_menu_data.ui_data.inv_origin,
				SHOP_INVENTORY_ROWS,
				len(shop_menu_data.shop.inventory),
			)
		}
	}
	shop_update_icons()
}

shop_update_icons :: proc() {
}

shop_buy_item :: proc() {
}

sell_item :: proc() {
}
