package game

import rl "vendor:raylib"

queue_text_effect_character :: proc(target: ^Character, text: cstring, color := rl.WHITE) {
	if battle.active {
		target := get_combatant(target)
		append(&battle.text, Process_Text_Effect{color = color, coord = target.coord, text = text})
	} else if world_menu_active {
		if i, row, ok := get_world_menu_target_character_position(target); ok {
			coord := tile_to_pixel(9 + 2 * (f32(i) - 3 * row), 6 + 2.5 * row)
			append(&world_menu_text_effects, Process_Text_Effect{color = color, coord = coord, text = text})
		}
	}
}

queue_battle_skill :: proc(actor: int, targets: Target_Selection, skill: Skill) {
	battle.combatants[actor].t -= skill.cost
	append(&battle.skill_plays, Battle_Skill_Play{actor, targets, skill, skill.windup})
}

center_rect_on_rect :: proc(r1, r2: Rect) -> (r: Rect) {
	r.width = r1.width
	r.height = r1.height
	r.x = r2.x - zoom * (r1.width - r2.width) / 2
	r.y = r2.y - zoom * (r1.height - r2.height) / 2
	return
}

center_rect_on_combatant :: proc(r1: Rect, c: Combatant) -> Rect {
	t: Atlas_Texture
	switch v in c.visual.variant {
	case Texture_Name:
		t = atlas_textures[v]
	case Animation:
		t = atlas_textures[v.current_frame]
	}
	rc: Rect
	rc.x = c.coord.x
	rc.y = c.coord.y
	rc.width = t.document_size.x
	rc.height = t.document_size.y
	return center_rect_on_rect(r1, rc)
}

center_animation_on_combatant :: proc(a: Animation_Name, c: Combatant) -> Rect {
	t := atlas_textures[atlas_animations[a].first_frame]
	ra: Rect
	ra.width = t.document_size.x
	ra.height = t.document_size.y
	return center_rect_on_combatant(ra, c)
}

center_rect :: proc {
	center_animation_on_combatant,
	center_rect_on_combatant,
	center_rect_on_rect,
}
