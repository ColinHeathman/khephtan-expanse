class_name TerrainTileMap
extends TileMap

const TERRAIN_LAYER = 0
const ROAD_LAYER = 1

func get_tile_weight(map_coord: Vector2i):
	var is_road = self.get_cell_source_id(ROAD_LAYER, map_coord) >= 0
	if is_road:
		return 1.0
	var is_terrain = self.get_cell_source_id(TERRAIN_LAYER, map_coord) >= 0
	if is_terrain:
		return 3.0
	else:
		return -1
