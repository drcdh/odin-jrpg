TILESET_TERRAIN_PASSABLE = [
	[1,1,1,1],
	[1,1,1,1],
	[1,1,1,1],
	[0,0,0,0],
]

TILESET_TOWN_PASSABLE = [
	[0,0,0,0,0,0],
	[0,0,0,0,0,0],
	[0,0,0,0,0,0],
	[0,0,0,0,0,0],
	[0,0,1,0,0,0],
	[0,0,0,0,0,0],
]

def process(layers, first_gid):
	h, w = len(layers[0][1]), len(layers[0][1][0])
	p = [[True for _ in range(w)] for _ in range(h)]
	for i in range(w):
		for j in range(h):
			for l in range(len(layers)):
				tsp = globals()[layers[l][0].upper() + "_PASSABLE"]
				# print(f"{l=} {j=} {i=} {first_gid=}")
				t = layers[l][1][j][i]-first_gid[l]
				if t < 0: continue
				# print(t, t//len(tsp), t%len(tsp[0]))
				p[j][i] = p[j][i] and tsp[t//len(tsp)][t%len(tsp[0])]
	return p
