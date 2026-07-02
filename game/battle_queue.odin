package game

import "core:container/queue"
import "core:fmt"
import rl "vendor:raylib"

queue_battle_animation :: proc(event: Play_Animation) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect_ee :: proc(event: Battle_Effect_Event) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect_aten :: proc(actor, target: ^Combatant, effect: Effect) {
	queue_battle_effect_ee(Battle_Effect_Event{actor, target, effect})
}

queue_battle_effect :: proc {
	queue_battle_effect_aten,
	queue_battle_effect_ee,
}

queue_battle_sound :: proc(event: Play_Sound) {
	queue.push_back(&battle_event_queue, event)
}

queue_text_effect :: proc(event: Text_Effect) {
	queue.push_back(&battle_event_queue, event)
}

queue_text_effect_character :: proc(target: ^Character, text: cstring, color := rl.WHITE) {
	if battle_active {
		target := get_combatant(target)
		queue_text_effect(Text_Effect{color = color, coord = target.coord, text = text})
	} else if world_menu_active {
		if i, row, ok := get_world_menu_target_character_position(target); ok {
			coord := tile_to_pixel(9 + 2 * (f32(i) - 3 * row), 6 + 2.5 * row)
			append(&world_menu_text_effects, Process_Text_Effect{color = color, coord = coord, text = text})
		}
	}
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

queue_battle_skill :: proc(actor, target: ^Combatant, skill: Skill) {
	append(&battle_skills, Battle_Skill_Play{actor, target, skill, skill.windup})
}

queue_battle_skill_events_fields :: proc(actor, target: ^Combatant, skill: Skill) {
	fmt.println(actor.name, "uses", skill.name, "on", target.name)

	animation := Animation_Name.Ffvi_Stars if skill.animation == nil else skill.animation
	sound := Sound_Name.Whack if skill.sound == nil else skill.sound

	queue_battle_sound(Play_Sound{sound = sound})

	r := center_animation_on_combatant(animation, target^)

	queue_battle_animation(Play_Animation{animation = animation, offset = {r.x, r.y}})
	queue_battle_effect(actor, target, skill.effect)

	actor.windup = false
	actor.t -= skill.cost
}

queue_battle_skill_events_struct :: proc(play: Battle_Skill_Play) {
	queue_battle_skill_events_fields(play.actor, play.target, play.skill)
}

queue_battle_skill_events :: proc {
	queue_battle_skill_events_fields,
	queue_battle_skill_events_struct,
}

roll_for_counter :: proc(actor, target: ^Character, risk: f32 = 1) {
}
