package game

Skill :: struct {
	name:      string,
	effect:    Effect,
	targeting: Targeting_Type,
	windup:    int,
	cost:      int,
	cooldown:  int,
	animation: Animation_Name,
	sound:     Sound_Name,
}

Charge :: u8
CHARGE_MAX :: 255
CHARGE_DECAY :: 10

Skill_Set :: bit_set[Skill_Name]

Skill_Set_C :: struct {
	charges: [len(Skill_Name)]Charge,
	skills:  Skill_Set,
}

skill_in_set_bit_set :: proc(k: Skill_Name, s: Skill_Set) -> bool {
	return k in s
}

skill_in_set_c :: proc(k: Skill_Name, s: Skill_Set_C) -> bool {
	return skill_in_set_bit_set(k, s.skills)
}

skill_in_set :: proc {
	skill_in_set_bit_set,
	skill_in_set_c,
}

skill_set_charge_tick :: proc(ssc: ^Skill_Set_C) {
	for k in Skill_Name {
		c := ssc.charges[k]
		if skill_in_set(k, ssc.skills) {
			dc := u8(500 / skills[k].cooldown) if skills[k].cooldown > 0 else CHARGE_MAX
			if CHARGE_MAX - c <= dc {
				ssc.charges[k] = CHARGE_MAX
			} else {
				ssc.charges[k] += dc
			}
		} else {
			if c <= CHARGE_DECAY {
				ssc.charges[k] = 0
			} else {
				ssc.charges[k] -= CHARGE_DECAY
			}
		}
	}
}
