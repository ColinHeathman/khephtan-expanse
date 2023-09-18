class_name MapPlace
extends Node2D

@export var fix_position_at_start: bool = false
@export var is_pyramid: bool = false
@export var dialog_deck: DialogDeck
@export var win_dialog: Dialog
@export var visited_dialog: Dialog

var _terrain: TileMap
var obstruction_points: Array[Vector2] = []
var interaction_points: Array[Vector2] = []
var visited = false

func _ready() -> void:
	if has_node("%Lights"):
		%Lights.modulate = Color(1.0,1.0,1.0,0.0)
	self.add_to_group("Resettable")

func _read_keymap() -> void:
	for cell in %KeyMap.get_used_cells(0):
		var coord = %KeyMap.get_cell_atlas_coords(0, cell)
		if coord.x == 0:
			interaction_points.push_back(%KeyMap.map_to_local(cell))
		if coord.x == 1:
			obstruction_points.push_back(%KeyMap.map_to_local(cell))
	%KeyMap.queue_free()

func fix_position() -> void:
	var default_offset = Vector2(0, 8)
	var points_offset = %KeyMap.position - default_offset
	var map_coord = _terrain.local_to_map(_terrain.to_local(self.global_position))
	if fix_position_at_start:
		self.global_position = _terrain.to_global(_terrain.map_to_local(map_coord)) - points_offset

func on_game_reset():
	self.visited = false
