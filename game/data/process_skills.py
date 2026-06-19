import csv

from processing import name_to_enum

skills = []
def odin_skill(row):
	return {
		"name": row["name"],
		"effect": "." + row["effect"],
		"targeting": "." + row["targeting"],
		"power": row["power"] or 0,
		"windup": row["windup"] or 0,
		"cost": row["cost"] or 0,
		"cooldown": row["cooldown"] or 0,
		"animation": ("." + row["animation"]) if row["animation"] else "nil",
		"sound": ("." + row["sound"]) if row["sound"] else "nil",
	}
def write_skill(f, oskill):
	f.write("\t{{ \"{name}\", {effect}, {targeting}, {power}, {windup}, {cost}, {cooldown}, {animation}, {sound} }},\n".format(**oskill))

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
out_f.write("}\n")

out_f.write(f"skills := [{len(skills)}]Skill {{\n")
for skill in skills:
	write_skill(out_f, skill)
out_f.write("}\n")

out_f.close()

