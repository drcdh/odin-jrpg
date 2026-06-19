import csv

from processing import name_to_enum

items = []
def odin_consumable(row):
	skill = row.get("skill")
	return {
		"name": row["name"],
		"skill": f".{skill}" if skill else "nil",
	}
def odin_equippable(row):
	return {
		"name": row["name"],
		"slot": "." + row["slot"],
		"stats_add": "{{ {}, {}, {}, {}, {}, {} }}".format(
			row["ahp"] or 0,
			row["aof"] or 0,
			row["ade"] or 0,
			row["apo"] or 0,
			row["apd"] or 0,
			row["asp"] or 0,
		),
		"stats_mul": "{{ {}, {}, {}, {}, {}, {} }}".format(
			row["mhp"] or 0,
			row["mof"] or 0,
			row["mde"] or 0,
			row["mpo"] or 0,
			row["mpd"] or 0,
			row["msp"] or 0,
		),
	}

def write_item(f, oitem):
	if "skill" in oitem:
		f.write("\t{{ \"{name}\", {skill} }},\n".format(**oitem))
	else:
		f.write("\t{{ \"{name}\", Equippable{{ {stats_add}, {stats_mul}, {slot} }} }},\n".format(**oitem))

with open("data/consumables.csv") as f:
	reader = csv.DictReader(f, delimiter=",")
	for row in reader:
		items.append(odin_consumable(row))

with open("data/equippables.csv") as f:
	reader = csv.DictReader(f, delimiter=",")
	for row in reader:
		items.append(odin_equippable(row))

with open("item_data.odin", "w") as f:
	f.write("package game\n\n")
	f.write("Item_Name :: enum {\n")
	for item in items:
		enum = name_to_enum(item["name"])
		f.write(f"\t{enum},\n")
	f.write("\tNone,\n")
	f.write("}\n\n")

	f.write(f"items := [{len(items)}]Item {{\n")
	for item in items:
		write_item(f, item)
	f.write("}\n")

