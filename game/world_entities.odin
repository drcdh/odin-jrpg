package game

import hm "core:container/handle_map"
import "core:fmt"

Entity_Handle :: distinct hm.Handle16

World_Entities :: struct {
	entities: hm.Static_Handle_Map(128, Entity, Entity_Handle),
	id_map:   map[Id]Entity_Handle,
}

last_gen_id := max(Id) / 2

world_entities: World_Entities

delete_world_entities :: proc() {
	// call when program ends
	clear_world_entities()
	delete(world_entities.id_map)
}

draw_world_entities :: proc() {
	for z in 0 ..= Z_MAX {
		it := hm.iterator_make(&world_entities.entities)
		for e, _ in hm.iterate(&it) {
			if !e.disabled && entity_at_z(e, z) {
				draw_entity(e)
			}
		}
	}
}

update_world_entities :: proc(dt: f32) {
	it := hm.iterator_make(&world_entities.entities)
	for e, _ in hm.iterate(&it) {
		update_entity(dt, e)
	}
}

add_world_entity :: proc(e: Entity) {
	if h, ok := world_entities.id_map[e.id]; ok {
		fmt.printfln("Id %d already in world_entities.id_map", e.id)
		if existing := get_world_entity(h); existing != nil {
			fmt.printfln(
				"OOPS: attempting to add an entity %s with id %d, but entity %s is already using it",
				e.n,
				e.id,
				existing.n,
			)
			panic("Entity Id collision")
		}
	}
	world_entities.id_map[e.id] = hm.add(&world_entities.entities, e)
}

new_id :: proc() -> Id {
	new_id := last_gen_id + 1
	for {
		if new_id in world_entities.id_map {
			new_id += 1
			if new_id == 0 {panic("overflowed generating world entity id")}
		} else {break}
	}
	return Id(new_id)
}

clear_world_entities :: proc() {
	hm.clear(&world_entities.entities)
	clear_map(&world_entities.id_map)
}

get_world_entity_handle :: proc(id: Id) -> Entity_Handle {
	return world_entities.id_map[id]
}

get_world_entity_by_id :: proc(id: Id) -> ^Entity {
	return hm.get(&world_entities.entities, world_entities.id_map[id]) or_else nil
}

get_world_entity_by_handle :: proc(h: Entity_Handle) -> ^Entity {
	return hm.get(&world_entities.entities, h) or_else nil
}

get_world_entity :: proc {
	get_world_entity_by_handle,
	get_world_entity_by_id,
}

get_world_entity_at_tile :: proc(t: Tile_Coord, skip: Maybe(Id)) -> ^Entity {
	it := hm.iterator_make(&world_entities.entities)
	for e, _ in hm.iterate(&it) {
		if e.tile == t && !e.disabled && e.id != skip {
			return e
		}
	}
	return nil
}

remove_world_entity :: proc(id: Id) {
	if hr, ok := world_entities.id_map[id]; ok {
		hm.remove(&world_entities.entities, hr)
		delete_key(&world_entities.id_map, id)
	}
}

set_world_entity_busy :: proc(id: Id, busy: bool) {
	e := get_world_entity(id)
	e.busy = busy
}

set_world_entity_disabled :: proc(id: Id, disabled: bool) {
	get_world_entity(id).disabled = disabled
}

set_world_entity_face :: proc(id: Id, face: Face) {
	get_world_entity(id).face = face
}

set_world_entity_face_party :: proc(id: Id) {
	e := get_world_entity(id)
	pc := hm.get(&world_entities.entities, pc_handle)
	e.face = face_toward(e, pc)
	set_sprite_tag(&e.v, e.face)
}

set_world_entity_light :: proc(id: Id, light: f16) {
	get_world_entity(id).light = light
}

set_world_entity_sprite :: proc(id: Id, sprite_name: Sprite_Name) {
	get_world_entity(id).v = create_sprite_state(sprite_name)
}

set_world_entity_tag :: proc(id: Id, tag: Sprite_Tag) {
	set_sprite_tag(&get_world_entity(id).v, tag)
}

set_world_entity_talk_script :: proc(id: Id, script: Entity_Script) {
	get_world_entity(id).talk = script
}

set_world_entity_trap_script :: proc(id: Id, script: Entity_Script) {
	get_world_entity(id).trap = script
}

set_world_entity_state :: proc(id: Id, state: Entity_State) {
	get_world_entity(id).state = state
}
