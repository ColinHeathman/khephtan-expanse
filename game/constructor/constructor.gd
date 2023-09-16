extends Node

const player_scn = preload("res://game/player/player.tscn")
const player_start_dialog = preload("res://game/player/player_start_dialog.tres")

signal reset_game

func _ready() -> void:
	if has_node("/root/Main"):
		setup()

func setup() -> void:
	if $/root/Main/%PlayerStart and $/root/Main/%Terrain:
		_setup_map()
		_setup_player()
		_setup_map_entities()
		_setup_navigation()
		_setup_menus()
		_setup_fog()
		_setup_map_objects()
		_setup_game_reset()
		$/root/DialogMenu.show_dialog(player_start_dialog)

func _setup_map() -> void:
	for map_place in get_tree().get_nodes_in_group("MapPlaces"):
		map_place._terrain = $/root/Main/%Terrain
		map_place.fix_position()
	
func _setup_player() -> void:
	var player = player_scn.instantiate()
	player._terrain = $/root/Main/%Terrain
	player.position = $/root/Main/%PlayerStart.global_position
	player.add_to_group("Resettable")
	$/root/Main.add_child(player)
	player._fix_position()

	if $/root/DefaultCamera:
		var camera_remote_transform = RemoteTransform2D.new()
		camera_remote_transform.update_position = true
		camera_remote_transform.update_rotation = false
		camera_remote_transform.update_scale = false
		camera_remote_transform.remote_path = NodePath("/root/DefaultCamera")
		player.add_child(camera_remote_transform)
		$/root/DefaultCamera.enabled = true
	
	$/root/PlayerStatsService.hit_points_changed.connect($/root/Hud.update_hit_points)
	$/root/PlayerStatsService.wisdom_changed.connect($/root/Hud.update_wisdom)
	$/root/PlayerStatsService.diplomacy_changed.connect($/root/Hud.update_diplomacy)
	$/root/PlayerStatsService.currency_changed.connect($/root/Hud.update_currency)
	$/root/Hud.show()

func _setup_map_entities() -> void:
	for map_entity in get_tree().get_nodes_in_group("MapEntities"):
		map_entity._terrain = $/root/Main/%Terrain
		map_entity._fix_position()
		if map_entity is Wanderer:
			var wanderer = map_entity as Wanderer
			$/root/TurnController.new_turn.connect(wanderer.on_next_turn.unbind(1))
			wanderer._player = $/root/Main/Player

func _setup_navigation() -> void:
	$/root/NavigationService._terrain = $/root/Main/%Terrain
	for map_place in get_tree().get_nodes_in_group("MapPlaces"):
		map_place._read_keymap()
		$/root/NavigationService.add_place(map_place)
	$/root/NavigationService._read_terrain()
	
	$/root/MovementUI._player = $/root/Main/Player
	$/root/MovementUI.move_to.connect($/root/Main/Player.move_to_coord)
	$/root/MovementUI.move_cost.connect($/root/MovementService.subtract_move_points)
	$/root/MovementService.move_points_changed.connect($/root/MovementUI.update_colors.unbind(1))

func _setup_menus() -> void:
	$/root/NextTurnMenu.next_turn.connect($/root/TurnController.next_turn)
	$/root/NextTurnMenu.show()
	$/root/TurnController.new_turn.connect($/root/MovementService.reset_move_points.unbind(1))
	$/root/TurnController.daytime.connect($/root/GlobalEnvironment.transition_to_day)
	$/root/TurnController.nightime.connect($/root/GlobalEnvironment.transition_to_night)
	$/root/TurnController.daytime.connect($/root/Main/Player.transition_to_day)
	$/root/TurnController.nightime.connect($/root/Main/Player.transition_to_night)
	$/root/TurnController.new_turn.connect($/root/NextTurnMenu.set_turn)
	$/root/TurnController.new_turn.connect($/root/PlayerStatsService.on_next_turn.unbind(1))
	$/root/PlayerStatsService.supplies_changed.connect($/root/NextTurnMenu.update_supplies)
	$/root/NextTurnMenu.update_supplies()
	$/root/MovementUI.moving.connect($/root/NextTurnMenu.set_disabled)
	$/root/MovementUI.show()
	$/root/InGameMenu._on_start_button_pressed()
	$/root/DialogMenu.dialog_visible.connect($/root/NextTurnMenu.set_disabled)

func _setup_fog() -> void:
	$/root/FogOfWar._player = $/root/Main/Player
	$/root/FogOfWar.reset(Rect2i(-100, -100, 300, 300))
	$/root/Main/Player.moved.connect($/root/FogOfWar.on_player_move.unbind(1))
	$/root/TurnController.new_turn.connect($/root/FogOfWar.on_player_move.unbind(1))
	$/root/FogOfWar.call_deferred("on_player_move")

func _setup_map_objects() -> void:
	$/root/InteractionService._player = $/root/Main/Player
	$/root/InteractionService._terrain = $/root/Main/%Terrain
	$/root/Main/Player.done_move.connect($/root/InteractionService.on_player_move)
	for map_place in get_tree().get_nodes_in_group("MapPlaces"):
		$/root/InteractionService.add_place(map_place)

func _setup_game_reset() -> void:
	$/root/InGameMenu.restart.connect(self.do_game_reset)
	for node in get_tree().get_nodes_in_group("Resettable"):
		assert("on_game_reset" in node and node.on_game_reset is Callable)
		self.reset_game.connect(node.on_game_reset)

func do_game_reset() -> void:
	$/root/FogOfWar.reset(Rect2i(-100, -100, 300, 300))
	$/root/MovementUI.clear()
	self.reset_game.emit()
	show_stats_picker()
	
func show_stats_picker() -> void:
	$/root/PlayerStatsPicker.show()
	$/root/PlayerStatsPicker.done.connect(self.done_picking_stats)

func done_picking_stats() -> void:
	$/root/PlayerStatsPicker.done.disconnect(self.done_picking_stats)
	$/root/PlayerStatsService._hit_points = $/root/PlayerStatsPicker.constitution
	$/root/PlayerStatsService._constitution = $/root/PlayerStatsPicker.constitution
	$/root/PlayerStatsService._wisdom = $/root/PlayerStatsPicker.wisdom
	$/root/PlayerStatsService._diplomacy = $/root/PlayerStatsPicker.diplomacy
	$/root/Hud.update_hud()
	$/root/DialogMenu.show_dialog(player_start_dialog)
