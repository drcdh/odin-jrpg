import csv

from processing import name_to_enum

def constant_f(row):
	return int(row["const"] or 0)
def power_f(row):
	return int(row["power"] or 0)
def psy_power_f(row):
	return int(row["psypow"] or 0)
def pierce_f(row):
	return int(row["pierce"] or 0)
def psy_pierce_f(row):
	return int(row["psyprc"] or 0)
def chance_f(row):
	return int(row["chance"] or 100)
def risk_f(row):
	return int(row["risk"] or 100)
def ranged_f(row):
	return "true" if row["risk"] else "false"
def status_f(row):
	return row["status"]
def traits_f(row):
	return row["traits"]

def skill_effect(row):
	effect = row["effect"]
	if effect == "Attack":
		constant = constant_f(row)
		power = power_f(row)
		psy_power = psy_power_f(row)
		pierce = pierce_f(row)
		psy_pierce = psy_pierce_f(row)
		accuracy = chance_f(row)
		risk = risk_f(row)
		# traits = traits_f(row)
		ranged = ranged_f(row)
		return f"Effect_Attack{{ {constant=}, {power=}, {psy_power=}, {pierce=}, {psy_pierce=}, {accuracy=}, {risk=}, ranged={ranged} }}"
	elif effect == "Heal_Hp":
		constant = constant_f(row)
		power = power_f(row)
		return f"Effect_Heal_Hp{{ {constant=}, {power=} }}"
	elif effect == "Add_Status":
		chance = chance_f(row)
		status = status_f(row)
		return f"Effect_Add_Status{{ {chance=}, status={status} }}"
	elif effect == "Remove_Status":
		chance = chance_f(row)
		status = status_f(row)
		return f"Effect_Remove_Status{{ {chance=}, status={status} }}"
	elif effect == "Level_Up":
		n = constant_f(row)
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

