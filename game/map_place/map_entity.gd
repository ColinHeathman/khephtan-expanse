class_name MapEntity
extends Node2D

const tween_duration = 0.125

var _terrain: TileMap
var _map_coord: Vector2i
var _initial_map_coord: Vector2i
var map_coord: Vector2i:
	get = get_map_coord, set = set_map_coord

signal moved(Vector2i)
signal done_move(Vector2i)

func _fix_position() -> void:
	var fixed_map_coord = _terrain.local_to_map(_terrain.to_local(self.global_position))
	_initial_map_coord = fixed_map_coord
	set_map_coord(fixed_map_coord)

func get_map_coord() -> Vector2i:
	return _map_coord

func set_map_coord(new_map_coord: Vector2i) -> void:
	_flip_direction(_map_coord, new_map_coord)
	_map_coord = new_map_coord
	self.global_position = _terrain.to_global(_terrain.map_to_local(_map_coord))
	moved.emit(_map_coord)

func move_to_coord(new_map_coord: Vector2i) -> void:
	_flip_direction(_map_coord, new_map_coord)
	_map_coord = new_map_coord
	var final_pos = _terrain.to_global(_terrain.map_to_local(new_map_coord))
	var tween = self.create_tween().bind_node(self).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "global_position", final_pos, tween_duration)
	tween.tween_callback(self.on_done_move)
	moved.emit(_map_coord)

func _flip_direction(move_from: Vector2i, move_to: Vector2i):
	var from_x = float(_terrain.map_to_local(move_from).x)
	var to_x = float(_terrain.map_to_local(move_to).x)

	if to_x < from_x:
		self.scale = Vector2(1.0, 1.0)
	else:
		self.scale = Vector2(-1.0, 1.0)

func on_game_reset():
	set_map_coord(_initial_map_coord)

func on_done_move():
	self.done_move.emit(_map_coord)
