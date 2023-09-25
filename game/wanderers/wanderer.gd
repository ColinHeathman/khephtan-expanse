class_name Wanderer
extends MapEntity

var _player: Player

var _nav_path: Dictionary
var _nav_path_i: int
var _moving: bool = false
var _pseudorandom: Psuedorandom

signal moving(bool)

@export var interaction: Dialog
@export var visited_interaction: Dialog
@export var remove_on_interaction: bool = false
@export var pursues_player: bool = false
@export var pursuit_move_points: int = 4
var move_points_remaining: int
var player_visited: bool = false


func _init() -> void:
	var deck = [
		TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
		TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
		TileSet.CELL_NEIGHBOR_LEFT_SIDE,
		TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	]
	_pseudorandom = Psuedorandom.new(deck, 4)

func _ready() -> void:
	self.done_move.connect(_on_done_move)

func move_to_coord(new_map_coord: Vector2i) -> void:
	super.move_to_coord(new_map_coord)
	%MoveAnimationPlayer.play("bounce")

func on_next_turn():
	var distance: float = Vector2(self.map_coord).distance_to(Vector2(_player.map_coord))
	if pursues_player and distance < 5.0:
		_nav_path = $/root/NavigationService.get_navigation_path(self.map_coord, _player.map_coord)
		_nav_path_i = 1

	elif distance < 25.0:
		var next_cell = _terrain.get_neighbor_cell(self.map_coord, _pseudorandom.get_random_item())
		_nav_path = $/root/NavigationService.get_navigation_path(self.map_coord, next_cell)
		_nav_path_i = 1
		
	if "path" not in _nav_path or _nav_path.path.size() == 0:
		return
	_start_move()

func _start_move() -> void:
	_moving = true
	move_points_remaining = pursuit_move_points
	moving.emit(_moving)
	%MoveCadence.start()
	_next_move()

func _next_move() -> void:
	# Valid move?
	if (
		"weights" not in _nav_path
		or _nav_path_i >= _nav_path.weights.size()
		or move_points_remaining - min(_nav_path.weights[_nav_path_i], 2) <= 0
	):
		_stop_move()
		return
	
	move_points_remaining -= 1
	%MoveSoundPlayer.play()
	self.move_to_coord(_nav_path.path[_nav_path_i])
	
	# Done?
	_nav_path_i += 1
	if _nav_path_i >= _nav_path.path.size():
		_stop_move()

func _stop_move() -> void:
	_moving = false
	moving.emit(_moving)
	%MoveCadence.stop()
	
func _on_done_move(move_map_coord: Vector2i) -> void:
	if move_map_coord == _player.map_coord:
		do_interaction()
		_stop_move()
	show_or_hide()

func show_or_hide() -> void:
	var visibility = $/root/FogOfWar.get_tile_visibility(map_coord)
	if visibility == $/root/FogOfWar.TileVisibility.VISIBLE:
		self.show()
	else:
		self.hide()

func do_interaction() -> void:
	if not player_visited:
		player_visited = true
		if interaction != null:
			$/root/DialogMenu.show_dialog(interaction)
	else:
		if visited_interaction != null:
			$/root/DialogMenu.show_dialog(visited_interaction)
	if remove_on_interaction:
		self.queue_free()
