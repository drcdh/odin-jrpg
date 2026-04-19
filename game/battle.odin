package game

import "core:fmt"

import rl "vendor:raylib"

MAX_COMBATANTS :: MAX_ENCOUNTER_SIZE + MAX_PARTY_SIZE

battle_combatants := [MAX_COMBATANTS]Combatant{}
battle_active := false
battle_num_combatants := 0

NPC_Combatant :: struct {
	character: Character,
	turn:      Turn,
}

PC_Combatant :: struct {
	pc: ^PC,
}

CHARACTER_EFFECT :: proc(actor, target: ^Stats)

Character_Effect :: struct {
	f: CHARACTER_EFFECT,
}

Battle_Effect :: union {
	Character_Effect,
}

CE_ATTACK :: Character_Effect {
	f = proc(actor, target: ^Stats) {
		target.hitpoints -= actor.offense - target.defense
	},
}

Battle_Action :: struct {
	name:   cstring,
	// effect: Battle_Effect,
	effect: Character_Effect,
	// message: cstring,
}

BA_ATTACK :: Battle_Action {
	name   = "Attack",
	effect = CE_ATTACK,
	// message = "{:actor} attacks {:target}!",
}

Turn :: proc() -> Battle_Action

Combatant_State :: struct {}

Nil_Combatant :: struct {}

Combatant_Variant :: union {
	Nil_Combatant,
	NPC_Combatant,
	PC_Combatant,
}

Combatant :: struct {
	// state: Combatant_State,
	variant: Combatant_Variant,
}

draw_battle :: proc() {
	rl.DrawRectangleV(Pixel_Coord{50, 50}, Pixel_Dim{800, 800}, TEXT_DISPLAY_BACKGROUND)
	baddy_y := i32(60)
	party_y := i32(60)
	for i in 0 ..< battle_num_combatants {
		#partial switch v in battle_combatants[i].variant {
		case NPC_Combatant:
			rl.DrawText(
				fmt.caprintf("%d/%d: %s", i + 1, battle_num_combatants, v.character.name),
				60,
				baddy_y,
				18,
				TEXT_COLOR,
			)
			baddy_y += 60
		case PC_Combatant:
			rl.DrawText(fmt.caprintf("%d/%d: %s", i + 1, battle_num_combatants, v.pc.name), 400, party_y, 18, TEXT_COLOR)
			party_y += 60
		}
	}
}
