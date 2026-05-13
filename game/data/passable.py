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
	[0,0,1,1,1,0],
	[0,0,0,0,0,0],
]

TILESET_OVERWORLD_PASSABLE = [
	[0,0,0,1,1,1,1,1,1],
	[0,0,0,1,1,1,1,1,1],
	[0,0,0,1,0,1,1,0,0],
	[1,1,1,1,1,1,0,0,0],
	[1,1,1,0,0,0,0,0,0],
	[1,1,1,0,0,0,0,0,0],
]

def tile_passibility(t, tileset_firstgids):
	t0 = t
	i_ts = 0
	while i_ts + 1 < len(tileset_firstgids) and t >= tileset_firstgids[i_ts+1][1]:
		i_ts += 1
		t = t - tileset_firstgids[i_ts][1] + 1
	tsp = globals()[tileset_firstgids[i_ts][0].upper() + "_PASSABLE"]
	t -= 1
	j, i = t//len(tsp[0]), t%len(tsp[0])
	p = tsp[j][i]
	return p

def process(layers, tileset_firstgids):
	h, w = len(layers[0][1]), len(layers[0][1][0])
	p = [[True for _ in range(w)] for _ in range(h)]
	for i in range(w):
		for j in range(h):
			for l in range(len(layers)):
				if layers[l][0].startswith("Passible-"): continue
				t = layers[l][1][j][i]
				if t <= 0: continue
				p[j][i] = p[j][i] and tile_passibility(t, tileset_firstgids)
	return p
