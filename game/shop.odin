package game

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Shop :: struct {
	inventory: []Item_Name,
}

demo_shop := Shop {
	inventory = {
		.Potion,
		.Super_Potion,
		.Antidote,
		.Poisonous_Mushroom,
		.Thingamajig,
		.Doodad,
		.Deluxe_Doodad,
		.Postcard,
		.Generic_Trinket,
		.Mundane_Tchotchke,
		.Boost_Donut,
		.Tea,
		.Sword,
		.Beef_Bracer,
		.Chump_Charm,
		.Knife,
		.Rat_Smashing_Bat,
		.Beginners_Wand,
		.Speed_Ring,
	},
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
	switch shop_menu_data.ui_state {
	case .Inactive:
	case .Top:
		draw_animation(world_menu_icon, tile_to_pixel(.5 + f32(3 * shop_menu_data.ui_data.top), .75))
	case .Buy:
		draw_animation(
			world_menu_icon,
			tile_to_pixel(.5, 3 + shop_menu_data.ui_data.inv_row - shop_menu_data.ui_data.inv_origin),
		)
	case .Sell:
		draw_animation(
			world_menu_icon,
			tile_to_pixel(.5, 3 + shop_menu_data.ui_data.inv_row - shop_menu_data.ui_data.inv_origin),
		)
	case .Swap_Character:
		draw_animation(
			world_menu_icon,
			tile_to_pixel(11 + 2 * (shop_menu_data.ui_data.character % 2), 3 + shop_menu_data.ui_data.character / 2),
		)
	case .Swap_Slot:
		draw_animation(world_menu_icon, tile_to_pixel(10, 3 + shop_menu_data.ui_data.slot))
	case .Swap_Buy:
		draw_animation(
			world_menu_icon,
			tile_to_pixel(.5, 3 + shop_menu_data.ui_data.inv_row - shop_menu_data.ui_data.inv_origin),
		)
	}
}

shop_redraw_texture :: proc(pane: Shop_Pane) {
	fmt.printfln("Redrawing texture for %w", pane)
	rl.BeginTextureMode(shop_menu_data.textures[pane])
	draw_menu(PANE_DIM[pane])
	switch pane {
	case .Top:
		draw_text(1, .75, strings.clone_to_cstring("Buy   Sell  Swap", allocator = context.temp_allocator))
	case .Inventory:
		#partial switch shop_menu_data.ui_state {
		case .Top:
			switch shop_menu_data.ui_data.top {
			case 0:
				shop_draw_shop_inventory()
			case 1:
				shop_draw_party_inventory()
			case 2:
				shop_draw_shop_inventory(equipment = true)
			}
		case .Buy:
			shop_draw_shop_inventory()
		case .Sell:
			shop_draw_party_inventory()
		case .Swap_Character:
			shop_draw_shop_inventory(equipment = true)
		case .Swap_Slot:
			shop_draw_shop_inventory(equipment = true, slot = true)
		case .Swap_Buy:
			shop_draw_shop_inventory(equipment = true, slot = true)
		}
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

shop_draw_party_inventory :: proc() {
	for r in 0 ..< SHOP_INVENTORY_ROWS {
		if r >= len(inventory_order) {break}
		draw_text(1, 1 + f32(r), fmt.ctprint(items[inventory_order[r + shop_menu_data.ui_data.inv_origin]].name))
		// TODO: price
		// TODO: quantity, maybe
	}
}

shop_draw_shop_inventory :: proc(equipment := false, slot := false) {
	inventory :=
		filter_equippables(shop_menu_data.shop.inventory, allocator = context.temp_allocator) if equipment else shop_menu_data.shop.inventory
	for r in 0 ..< SHOP_INVENTORY_ROWS {
		if r >= len(inventory) {break}
		item_name := inventory[r + shop_menu_data.ui_data.inv_origin]
		tint := rl.WHITE if !slot || fits_in_slot(item_name, Equipment_Slot(shop_menu_data.ui_data.slot)) else rl.GRAY
		draw_text(1, 1 + f32(r), fmt.ctprint(items[item_name].name), tint)
		// TODO: price
		// TODO: quantity, maybe
	}
}

shop_reset_inventory_pos :: proc() {
	shop_menu_data.ui_data.inv_origin = 0
	shop_menu_data.ui_data.inv_row = 0
	shop_menu_data.stale[Shop_Pane.Inventory] = true
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
				shop_reset_inventory_pos() // TODO: only do this if previously Sell
			case 1:
				shop_menu_data.ui_state = .Sell
				shop_reset_inventory_pos() // TODO: only do this if previously Buy
			case 2:
				shop_menu_data.ui_state = .Swap_Character
			}
		} else if dx, ok := get_x_input().?; ok {
			shop_menu_data.ui_data.top = grid_change(shop_menu_data.ui_data.top, dx, 0, 3, 1)
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		}
	case .Buy:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Top
		} else if get_input(.ENTER) {
			if try_buy_item(shop_menu_data.shop.inventory[shop_menu_data.ui_data.inv_row]) {
				shop_menu_data.stale[Shop_Pane.Inventory] = true
			}
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.inv_row, shop_menu_data.ui_data.inv_origin = shift_windowed_selection(
				dy,
				shop_menu_data.ui_data.inv_row,
				shop_menu_data.ui_data.inv_origin,
				SHOP_INVENTORY_ROWS,
				len(shop_menu_data.shop.inventory),
			)
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		}
	case .Sell:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Top
		} else if get_input(.ENTER) {
			sell_item(inventory_order[shop_menu_data.ui_data.inv_row])
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.inv_row, shop_menu_data.ui_data.inv_origin = shift_windowed_selection(
				dy,
				shop_menu_data.ui_data.inv_row,
				shop_menu_data.ui_data.inv_origin,
				SHOP_INVENTORY_ROWS,
				len(inventory_order),
			)
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		}
	case .Swap_Character:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Top
		} else if get_input(.ENTER) {
			shop_menu_data.ui_state = .Swap_Slot
			shop_menu_data.stale[Shop_Pane.Equipment] = true
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		} else {
			m := get_menu_input()
			shop_menu_data.ui_data.character = grid_change(shop_menu_data.ui_data.character, m.x, m.y, 2, 3)
		}
	case .Swap_Slot:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Swap_Character
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		} else if get_input(.ENTER) {
			shop_menu_data.ui_state = .Swap_Buy
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.slot = grid_change(shop_menu_data.ui_data.slot, dy, 0, NUM_EQUIPMENT_SLOTS, 1)
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		}
	case .Swap_Buy:
		if get_input(.CANCEL) {
			shop_menu_data.ui_state = .Swap_Slot
		} else if get_input(.ENTER) {
			try_buy_item(
				filter_equippables(shop_menu_data.shop.inventory, allocator = context.temp_allocator)[shop_menu_data.ui_data.inv_row],
				equip = true,
			)
		} else if dy, ok := get_y_input().?; ok {
			shop_menu_data.ui_data.inv_row, shop_menu_data.ui_data.inv_origin = shift_windowed_selection(
				dy,
				shop_menu_data.ui_data.inv_row,
				shop_menu_data.ui_data.inv_origin,
				SHOP_INVENTORY_ROWS,
				len(filter_equippables(shop_menu_data.shop.inventory, allocator = context.temp_allocator)),
			)
			shop_menu_data.stale[Shop_Pane.Inventory] = true
		}
	}
	shop_update_icons()
}

shop_update_icons :: proc() {
	animation_update(&world_menu_icon, rl.GetFrameTime())
}

try_buy_item :: proc(item_name: Item_Name, equip := false) -> bool {
	if have_money(item_price(item_name)) {
		buy_item(item_name, equip)
		play_sound(.Kaching)
		return true
	} else {
		play_sound(.Blerp)
	}
	return false
}

buy_item :: proc(item_name: Item_Name, equip := false) {
	add_item(item_name)
	dec_money(item_price(item_name))
	if equip {
		pc := get_pc(shop_menu_data.ui_data.character)
		set_equipped_item(pc, Equipment_Slot(shop_menu_data.ui_data.slot), item_name)
	}
	play_sound(.Kaching)
}

sell_item :: proc(item_name: Item_Name) {
	remove_item(item_name)
	inc_money(item_price(item_name))
	play_sound(.Kaching)
}
