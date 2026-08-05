package game

import "core:fmt"
import "core:math/rand"

random_skill_random_target :: proc(actor_idx: int) {
	c := battle.combatants[actor_idx]
	available_skills: [dynamic]Skill_Name
	for charge, i in c.skills.charges {
		k := Skill_Name(i)
		if k in c.skills.skills && charge == CHARGE_MAX {
			append(&available_skills, k)
		}
	}
	if len(available_skills) > 0 {
		k := rand.choice(available_skills[:])
		fmt.printfln("%s picked skill %s", c.character.name, k)
		skill := skills[k]
		if target, valid := random_target(c.team, skill.targeting); valid {
			queue_battle_skill(actor_idx, target, skill)
		} else {
			fmt.printfln("no valid target for %v", k)
		}
	} else {
		fmt.printfln("%s twiddles their thumbs", c.character.name)
	}
}
