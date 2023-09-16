extends CanvasLayer

const DEFAULT_LAYER = 0
const DEFAULT_TERRAIN_SET = 0
const DEFAULT_TERRAIN = 0
const DEFAULT_SOURCE = 1
const DESTINATION_ATLAS_COORD = Vector2i(9,0)

const NORMAL_ATLAS_Y = 0
const ROUGH_ATLAS_Y = 1
const NOTENOUGH_ATLAS_Y = 2

var _player: MapEntity

var _nav_path: Dictionary
var _nav_path_i: int
var _moving: bool = false

signal move_to(Vector2i)
signal move_cost(float)
signal moving(bool)

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.is_pressed() && mouse_event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_handle_move_request()
		elif mouse_event.is_pressed() && mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			clear()

func _handle_move_request() -> void:
	var target_coord = _get_target_coord()
	if _is_destination(target_coord):
		if not _moving:
			_start_move()
		else:
			_stop_move()
	else:
		_stop_move()
		_draw_line_from_player(target_coord) 

func _get_target_coord() -> Vector2i:
	var target_pos = $/root/Main.get_global_mouse_position()
	return %LineTileMap.local_to_map(%LineTileMap.to_local(target_pos))

func _draw_line_from_player(target_coord: Vector2i) -> void:
	if _player and $/root/FogOfWar.get_tile_visibility(target_coord) != $/root/FogOfWar.TileVisibility.HIDDEN:
		var player_coord = _player.get_map_coord()
		_display_line(player_coord, target_coord)

func _display_line(from_coord: Vector2i, to_coord: Vector2i) -> void:
	_nav_path = $/root/NavigationService.get_navigation_path(from_coord, to_coord)
	if "path" not in _nav_path or _nav_path.path.size() == 0:
		return
	_nav_path_i = 1
	%LineTileMap.clear()
	%LineTileMap.set_cells_terrain_path(DEFAULT_LAYER, _nav_path.path, DEFAULT_TERRAIN_SET, DEFAULT_TERRAIN)
	%LineTileMap.set_cell(DEFAULT_LAYER, to_coord, DEFAULT_SOURCE, Vector2i(9,0))
	%LineTileMap.erase_cell(DEFAULT_LAYER, _nav_path.path[0])
	update_colors()

func update_colors() -> void:
	if not _moving and "path" in _nav_path:
		var movement_points = $/root/MovementService.move_points_remaining
		for i in range(1, _nav_path.path.size()):
			movement_points -= _nav_path.weights[i]
			var atlas_coord = %LineTileMap.get_cell_atlas_coords(DEFAULT_LAYER, _nav_path.path[i])
			
			if movement_points <= 0:
				atlas_coord.y = NOTENOUGH_ATLAS_Y
				%LineTileMap.set_cell(DEFAULT_LAYER, _nav_path.path[i], DEFAULT_SOURCE, atlas_coord)
				
			elif _nav_path.weights[i] > 1.0:
				atlas_coord.y = ROUGH_ATLAS_Y
				%LineTileMap.set_cell(DEFAULT_LAYER, _nav_path.path[i], DEFAULT_SOURCE, atlas_coord)

			else:
				atlas_coord.y = NORMAL_ATLAS_Y
				%LineTileMap.set_cell(DEFAULT_LAYER, _nav_path.path[i], DEFAULT_SOURCE, atlas_coord)

func _is_destination(map_coord: Vector2i) -> bool:
	var atlas_coord = %LineTileMap.get_cell_atlas_coords(DEFAULT_LAYER, map_coord)
	return (
		atlas_coord.x == DESTINATION_ATLAS_COORD.x
		and (
			atlas_coord.y == NORMAL_ATLAS_Y
			or atlas_coord.y == ROUGH_ATLAS_Y
			or atlas_coord.y == NOTENOUGH_ATLAS_Y
		)
	)

func _start_move() -> void:
	_moving = true
	moving.emit(_moving)
	%MoveCadence.start()
	_next_move()

func _next_move() -> void:
	# Valid move?
	if (
		"weights" not in _nav_path
		or _nav_path_i >= _nav_path.weights.size()
		or $/root/MovementService.move_points_remaining - _nav_path.weights[_nav_path_i] <= 0
	):
		_stop_move()
		return
	
	# Update UI
	%MoveSoundPlayer.play()
	%LineTileMap.erase_cell(DEFAULT_LAYER, _nav_path.path[_nav_path_i])
	
	# Signal moves
	move_to.emit(_nav_path.path[_nav_path_i])
	move_cost.emit(_nav_path.weights[_nav_path_i])
	
	# Done?
	_nav_path_i += 1
	if _nav_path_i >= _nav_path.path.size():
		_stop_move()

func _stop_move() -> void:
	_moving = false
	moving.emit(_moving)
	%MoveCadence.stop()

func clear() -> void:
	_stop_move()
	%LineTileMap.clear()

