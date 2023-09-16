extends Node

const FOG_LAYER = 0
const FOG_TERRAIN_SET = 0
const FOG_TERRAIN = 0
const FOG_SOURCE = 0
const FOG_ATLAS_COORD = Vector2i(0,0)

enum TileVisibility {
	HIDDEN = 0,
	IN_FOG = 1,
	VISIBLE = 2,
}

var _player: Player
var _revealed_cells: Array[Vector2i] = []

func reset(rect: Rect2i):
	for y in range(rect.position.y, rect.size.y):
		for x in range(rect.position.x, rect.size.x):
			%BlackTileMap.set_cell(FOG_LAYER, Vector2i(x,y), FOG_SOURCE, FOG_ATLAS_COORD)
			%FogTileMap.set_cell(FOG_LAYER, Vector2i(x,y), FOG_SOURCE, FOG_ATLAS_COORD)

func reveal_around_point(map_coord: Vector2i, radius: int):
	var cells = {}
	cells[map_coord] = 0
	var bfs_queue = []
	bfs_queue.push_back(map_coord)
	while bfs_queue.size() > 0:
		var parent = bfs_queue.pop_front()
		
		var distance = cells[parent] + 1
		if distance >= radius + 1:
			continue
			
		for item in %BlackTileMap.get_surrounding_cells(parent):
			if item in cells:
				continue
			else:
				cells[item] = distance
				bfs_queue.push_back(item)

	var outer_ring: Array[Vector2i] = []
	var inner_ring: Array[Vector2i] = []
	for coord in cells:
		var distance = cells[coord]
		if distance == radius:
			outer_ring.push_back(coord)
		else:
			inner_ring.push_back(coord)
	
	# Reset fog 
	for coord in _revealed_cells:
		%FogTileMap.set_cell(FOG_LAYER, coord, FOG_SOURCE, FOG_ATLAS_COORD)

	# Reveal
	for coord in inner_ring:
		%BlackTileMap.erase_cell(FOG_LAYER, coord)
		%FogTileMap.erase_cell(FOG_LAYER, coord)

	# Reveal through fog
	%FogTileMap.set_cells_terrain_connect(FOG_LAYER, outer_ring, FOG_TERRAIN_SET, FOG_TERRAIN)
		
	# Only paint mist around undiscovered areas
	var unrevealed_ring: Array[Vector2i] = []
	for coord in outer_ring:
		if get_tile_visibility(coord) == TileVisibility.HIDDEN:
			unrevealed_ring.push_back(coord)
	%BlackTileMap.set_cells_terrain_connect(FOG_LAYER, unrevealed_ring, FOG_TERRAIN_SET, FOG_TERRAIN)
	
	# Save for next time
	_revealed_cells = []
	for coord in inner_ring:
		_revealed_cells.push_back(coord)
	for coord in outer_ring:
		_revealed_cells.push_back(coord)

	# Reveal map entities
	for map_entity in get_tree().get_nodes_in_group("MapEntities"):
		if map_entity is Wanderer:
			(map_entity as Wanderer).show_or_hide()

func get_tile_visibility(map_coord: Vector2i) -> TileVisibility:
	if not (
		%BlackTileMap.get_cell_source_id(FOG_LAYER, map_coord) == FOG_SOURCE
		and %BlackTileMap.get_cell_atlas_coords(FOG_LAYER, map_coord) == FOG_ATLAS_COORD
	):
		if not (
			%FogTileMap.get_cell_source_id(FOG_LAYER, map_coord) == FOG_SOURCE
			and %FogTileMap.get_cell_atlas_coords(FOG_LAYER, map_coord) == FOG_ATLAS_COORD
		):
			return TileVisibility.VISIBLE
		else:
			return TileVisibility.IN_FOG
	else:
		return TileVisibility.HIDDEN

func on_player_move():
	var radius = _player.get_vision_radius()
	var map_coord = _player.get_map_coord()
	reveal_around_point(map_coord, radius)
