import csv

from processing import name_to_enum

def skill_effect(row):
	effect = row["effect"]
	if effect == "Attack":
		constant = int(row["v0"] or 0)
		power = int(row["v1"] or 0)
		psy_power = int(row["v2"] or 0)
		pierce = int(row["v3"] or 0)
		psy_pierce = int(row["v4"] or 0)
		accuracy = int(row["v5"] or 0)
		risk = int(row["v6"] or 0)
		# traits = row["v7"]
		ranged = "true" if row["v8"] else "false"
		return f"Effect_Attack{{ {constant=}, {power=}, {psy_power=}, {pierce=}, {psy_pierce=}, {accuracy=}, {risk=}, ranged={ranged} }}"
	elif effect == "Heal_Hp":
		constant = int(row["v0"] or 0)
		power = int(row["v1"] or 0)
		return f"Effect_Heal_Hp{{ {constant=}, {power=} }}"
	elif effect == "Add_Status":
		chance = int(row["v0"] or 0)
		status = row["v1"]
		return f"Effect_Add_Status{{ {chance=}, status={status} }}"
	elif effect == "Remove_Status":
		chance = int(row["v0"] or 0)
		status = row["v1"]
		return f"Effect_Remove_Status{{ {chance=}, status={status} }}"
	elif effect == "Level_Up":
		n = int(row["v0"] or 0)
		return f"Effect_Level_Up{{ {n=} }}"

skills = []
def odin_skill(row):
	return {
		"name": row["name"],
		"effect": skill_effect(row),
		"targeting": "." + row["targeting"],
		"windup": row["windup"] or 0,
		"cost": row["cost"] or 0,
		"cooldown": row["cooldown"] or 0,
		"animation": ("." + row["animation"]) if row["animation"] else "nil",
		"sound": ("." + row["sound"]) if row["sound"] else "nil",
	}
def write_skill(f, oskill):
	f.write("\t{{ \"{name}\", {effect}, {targeting}, {windup}, {cost}, {cooldown}, {animation}, {sound} }},\n".format(**oskill))

in_f = open("data/skills.csv")
reader = csv.DictReader(in_f, delimiter=",")
for row in reader:
	skills.append(odin_skill(row))
in_f.close()

out_f = open("skill_data.odin", "w")
out_f.write("package game\n\n")

out_f.write("Skill_Name :: enum {\n")

for skill in skills:
	enum = name_to_enum(skill["name"])
	out_f.write(f"\t{enum},\n")
out_f.write("}\n\n")

out_f.write(f"skills := [{len(skills)}]Skill {{\n")
for skill in skills:
	write_skill(out_f, skill)
out_f.write("}\n")

out_f.close()

