package game

import "core:container/queue"

queue_battle_animation :: proc(event: Play_Animation) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect_ee :: proc(event: Effect_Event) {
	queue.push_back(&battle_event_queue, event)
}

queue_battle_effect_aten :: proc(effect_name: Effect_Name, actor, target: ^Character, power: int) {
	queue_battle_effect_ee(Effect_Event{effect_name, actor, target, power})
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
	// fmt.printfln("centering on combatant with rect %w", rc)
	return center_rect_on_rect(r1, rc)
}

center_animation_on_combatant :: proc(a: Animation_Name, c: Combatant) -> Rect {
	t := atlas_textures[atlas_animations[a].first_frame]
	ra: Rect
	ra.width = t.document_size.x
	ra.height = t.document_size.y
	// fmt.printfln("centering animation %s with dim %.0fx%.0f", a, ra.width, ra.height)
	return center_rect_on_combatant(ra, c)
}

center_rect :: proc {
	center_animation_on_combatant,
	center_rect_on_combatant,
	center_rect_on_rect,
}

queue_battle_skill :: proc(actor, target: ^Combatant, skill: Skill) {
	animation := Animation_Name.Ffvi_Stars if skill.animation == nil else skill.animation
	sound := Sound_Name.Whack if skill.sound == nil else skill.sound

	queue_battle_sound(Play_Sound{sound = sound})

	r := center_animation_on_combatant(animation, target^)
	// fmt.println("centered rect is", r)
	queue_battle_animation(Play_Animation{animation = animation, offset = {r.x, r.y}})
	queue_battle_effect(skill.effect, actor.character, target.character, skill.power)
}
