package game

import rl "vendor:raylib"

queue_text_effect_character :: proc(target: ^Character, text: cstring, color := rl.WHITE) {
	if battle.active {
		target := get_combatant(target)
		append(&battle.text, Process_Text_Effect{color = color, coord = get_combatant_coord(target^), text = text})
	} else if world_menu_active() {
		if i, row, ok := get_world_menu_target_character_position(target); ok {
			coord := tile_to_pixel(9 + 2 * f32(i), 6 + 2.5 * row)
			world_menu_add_text_effect(text, coord, color)
		}
	}
}

queue_battle_skill :: proc(actor_idx: int, targets: Target_Selection, skill: Skill) {
	battle.combatants[actor_idx].t -= Ticks(skill.cost)
	battle.combatants[actor_idx].windup = true
	set_sprite_tag(&battle.combatants[actor_idx].visual, .LArm)
	append(&battle.skill_plays, Battle_Skill_Play{actor_idx, targets, skill, Ticks(skill.windup)})
}

center_rect_on_rect :: proc(r1, r2: Rect) -> (r: Rect) {
	r.width = r1.width
	r.height = r1.height
	r.x = r2.x - zoom * (r1.width - r2.width) / 2
	r.y = r2.y - zoom * (r1.height - r2.height) / 2
	return
}

center_rect_on_combatant :: proc(r1: Rect, c: Combatant) -> Rect {
	sprite_size := sprite_size(c.visual)
	rc: Rect
	rc.x = c.coord.x + c.coord_d.x
	rc.y = c.coord.y + c.coord_d.y
	rc.width = sprite_size.x
	rc.height = sprite_size.y
	return center_rect_on_rect(r1, rc)
}

center_animation_on_combatant :: proc(s: Sprite_Name, c: Combatant) -> Rect {
	sprite_size := sprite_size(s)
	ra: Rect
	ra.width = sprite_size.x
	ra.height = sprite_size.y
	return center_rect_on_combatant(ra, c)
}

center_rect :: proc {
	center_animation_on_combatant,
	center_rect_on_combatant,
	center_rect_on_rect,
}
