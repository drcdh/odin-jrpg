import pathlib
import pytiled_parser

def orderedpair_to_tile(c):
	return int(c.x//16), int(c.y//16)

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

	paths = []
	paths_enum = []

	for obj in obj_layer.tiled_objects:
		if isinstance(obj, pytiled_parser.tiled_object.Polygon) or isinstance(obj, pytiled_parser.tiled_object.Polyline):
			tile_coords = []
			path = obj.points
			origin = obj.coordinates
			for c in path:
				t = int((c.x + origin.x)//16), int((c.y + origin.y)//16)
				tile_coords.append(t)
			paths.append(tile_coords)
			paths_enum.append(obj.name.title())
		elif isinstance(obj, pytiled_parser.tiled_object.Point):
			name = obj.name.upper()
			pos = orderedpair_to_tile(obj.coordinates)
			out_f.write(f"{prefix}{name} :: Tile_Coord{{ {pos[0]}, {pos[1]} }}\n")
		else:
			print(f"dunno what a {type(obj)}: {obj}")

	out_f.write(f"{prefix}ROUTES := [][]Tile_Coord{{\n")
	for p in paths:
		out_f.write("{\n")
		for t in p:
			out_f.write(f"{{ {t[0]}, {t[1]} }},\n")
		out_f.write("},\n")
	out_f.write("}\n")

	for i, p in enumerate(paths_enum):
		out_f.write(f"{prefix}{p.upper()} :: {i}\n")

	out_f.close()
