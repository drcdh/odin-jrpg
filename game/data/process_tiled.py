import fnmatch
import os
import pathlib
import pytiled_parser

import passable

def orderedpair_to_tile(c):
	return int(c.x//16), int(c.y//16)

levels_data = []

def process_tmx(level_name, overworld=False):
	tmx_file = pathlib.Path(f"data/tiled/{level_name}.tmx")
	prefix = level_name.upper() + "_"
	out_f = open(f"{level_name}_data.odin", "w")

	out_f.write("package game\n")
	out_f.write("import rl \"vendor:raylib\"\n")

	map_layers = []
	paths = []
	paths_enum = []

	tmap = pytiled_parser.parse_map(tmx_file)

	tileset_firstgids = tuple((ts.name, ts.firstgid) for ts in tmap.tilesets.values())

	for layer in tmap.layers:
		if isinstance(layer, pytiled_parser.TileLayer):
			map_layers.append((layer.name, layer.data))
		elif isinstance(layer, pytiled_parser.ObjectLayer):
			for obj in layer.tiled_objects:
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
					print(f"unknown object type {type(obj)}: {obj}")
		else:
			print(f"unknown layer type {type(layer)}: {layer}")

	num_layers = len(map_layers)
	h_tiles = len(map_layers[0][1])
	w_tiles = len(map_layers[0][1][0])

	out_f.write(f"{prefix}WIDTH :: {w_tiles}\n")
	out_f.write(f"{prefix}HEIGHT :: {h_tiles}\n")

	out_f.write(f"{prefix}TILESETS := [{len(tileset_firstgids)}]Tileset_Id{{\n")
	for ts, _ in tileset_firstgids:
		out_f.write(f"\t.{ts.title()},\n")
	out_f.write(f"}}\n")

	out_f.write(f"{prefix}FIRSTGIDS := [{len(tileset_firstgids)}]int{{\n")
	for _, g in tileset_firstgids:
		out_f.write(f"\t{g},\n")
	out_f.write(f"}}\n")

	out_f.write(f"{level_name}_map := [{num_layers}][{h_tiles}][{w_tiles}]int{{\n")
	for i, (_, layer_data) in enumerate(map_layers):
		out_f.write(f"{{")
		for row in layer_data:
			out_f.write(f"{{ {str([max(0, r) for r in row])[1:-1]} }},\n")
		out_f.write("},\n")
	out_f.write("}\n")

	out_f.write(f"{prefix}PASSABLE := [{h_tiles}][{w_tiles}]u8 ")
	out_f.write(str(passable.process(map_layers, tileset_firstgids)).replace("[","{").replace("]", "}"))
	out_f.write("\n")

	out_f.write(f"{prefix}ROUTES := [][]Tile_Coord{{\n")
	for p in paths:
		out_f.write("{\n")
		for t in p:
			out_f.write(f"{{ {t[0]}, {t[1]} }},\n")
		out_f.write("},\n")
	out_f.write("}\n")

	for i, p in enumerate(paths_enum):
		out_f.write(f"{prefix}{p.upper()} :: {i}\n")

	out_f.write(f"""
render_{level_name} :: proc() {{
	map_rt = rl.LoadRenderTexture({w_tiles}*i32(tile_size), {h_tiles}*i32(tile_size))
	rl.BeginTextureMode(map_rt)
	for l in 0..<{num_layers} {{
		for j in 0..<{h_tiles} {{
			for i in 0..<{w_tiles} {{
				t := {level_name}_map[l][j][i]
				pos := tile_to_pixel({{i, j}})
				draw_tile_tmx(l, t, pos)
			}}
		}}
	}}
	rl.EndTextureMode()
}}
""")

	out_f.close()

def main():
	for file in os.listdir('./data/tiled'):
			if fnmatch.fnmatch(file, '*.tmx'):
				print(f"processing {file}")
				process_tmx(file[:-4])
			else:
				print(f"skipping {file}")

if __name__ == "__main__":
	main()
