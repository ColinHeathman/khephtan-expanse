extends Node

var _terrain: TerrainTileMap
var _obstructions = {}
var _astar = AStar2D.new()

func add_place(map_place: MapPlace) -> void:
	var base_pos = map_place.global_position
	for op in map_place.obstruction_points:
		var map_pos = base_pos + op
		var map_coord = _terrain.local_to_map(_terrain.to_local(map_pos))
		_obstructions[map_coord] = true

func _read_terrain() -> void:
	assert(_terrain != null)
	for coord in _terrain.get_used_cells(0):
		if coord in _obstructions:
			continue
		var weight = _terrain.get_tile_weight(coord)
		if weight <= 0:
			continue
		_astar.add_point(coord_to_id(coord), _terrain.map_to_local(coord), weight)

	for id in _astar.get_point_ids():
		var coord = id_to_coord(id)
		for neighbor in _terrain.get_surrounding_cells(coord):
			var coord_id = coord_to_id(coord)
			var neighbor_id = coord_to_id(neighbor)
			if (
				_terrain.get_cell_source_id(0, neighbor) >= 0
				and _astar.has_point(coord_id)
				and _astar.has_point(neighbor_id)
			):
				_astar.connect_points(coord_id, neighbor_id)

func coord_to_id(coord: Vector2i):
	coord += Vector2i(128,128)
	return coord.x + (coord.y << 10)

func id_to_coord(id: int):
	var size = 1 << 10
	return Vector2i(id % size, id / size) - Vector2i(128,128)

func get_navigation_path(from_coord: Vector2i, to_coord: Vector2i) -> Dictionary:
	var result = {}
	var from_coord_id = coord_to_id(from_coord)
	var to_coord_id = coord_to_id(to_coord)
	if (
		not _astar.has_point(from_coord_id)
		or not _astar.has_point(to_coord_id)
	):
		return result
	
	var id_path = _astar.get_id_path(from_coord_id, to_coord_id)
	var path: Array[Vector2i] = []
	path.resize(id_path.size())
	for i in range(0, id_path.size()):
		path[i] = id_to_coord(id_path[i])
	
	var weights: Array[float] = []
	weights.resize(id_path.size())
	for i in range(0, id_path.size()):
		weights[i] = _astar.get_point_weight_scale(id_path[i])
	
	result.path = path
	result.weights = weights
	
	return result

func is_navigable(map_coord: Vector2i) -> bool:
	var map_coord_id = coord_to_id(map_coord)
	return _astar.has_point(map_coord_id)
