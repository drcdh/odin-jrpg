import pathlib
import pytiled_parser

for level_name in ("level_0", "level_1", "level_2"):
	tmx_file = pathlib.Path(f"data/tiled/{level_name}.tmx")
	prefix = level_name.upper() + "_"
	out_f = open(f"{level_name}_data.odin", "w")
	tmap = pytiled_parser.parse_map(tmx_file)
	tile_layer = tmap.layers[0]
	obj_layer = tmap.layers[1]
	out_f.write("package game\n")
	out_f.write(f"{level_name}_map := Map{{\n")
	for row in tile_layer.data:
		out_f.write(f"{{ {str(row)[1:-1]} }},\n")
	out_f.write("}\n")
	for obj in obj_layer.tiled_objects:
		name = obj.name.upper()
		pos = int(obj.coordinates.x//16), int(obj.coordinates.y//16)
		out_f.write(f"{prefix}{name} :: Tile_Coord{{ {pos[0]}, {pos[1]} }}\n")
	out_f.close()
