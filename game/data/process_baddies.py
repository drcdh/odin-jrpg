import csv

baddy_id_enums = ["None"]


out_f = open("baddy_data.odin", "w")

out_f.write("""package game

baddy_templates := [?]Baddy_Template{
Baddy_Template {},
""")

n = 1

with open("data/baddies.csv") as f:
	reader = csv.DictReader(f, delimiter=",")
	for row in reader:
		baddy_id_enum = row["name"].replace("-", "_").replace(" ", "_").title()
		if not row["texture"]:
			row["texture"] = baddy_id_enum
		row["texture"] = row["texture"].title()
		if baddy_id_enum == baddy_id_enums[-1]:
			if n == 1:
				baddy_id_enums[-1] += "_1"
			n += 1
			baddy_id_enum += f"_{n}"
		else:
			n = 1
		baddy_id_enums.append(baddy_id_enum)
		out_f.write( "Baddy_Template {")
		out_f.write("""
	name = \"{name}\",
	hitpoints = {hitpoints},
	offense = {offense},
	defense = {defense},
	pOffense = {pOffense},
	pDefense = {pDefense},
	speed = {speed},
	texture = .{texture},
	turn = {turn},
""".format(**row))
		out_f.write("},\n")

out_f.write("""}

Baddy_Id :: enum {
""")

out_f.write(",\n".join(baddy_id_enums + [""]))
out_f.write("}\n")

out_f.write(f"NUM_BADDY_TEMPLATES :: {len(baddy_id_enums)}")

out_f.close()
