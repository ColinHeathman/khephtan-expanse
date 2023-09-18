extends Node

var _terrain: TerrainTileMap
var _player: Player
var _interactions = {}

func add_place(map_place: MapPlace) -> Dictionary:
	var base_pos = map_place.global_position
	for ip in map_place.interaction_points:
		var map_pos = base_pos + ip
		var map_coord = _terrain.local_to_map(_terrain.to_local(map_pos))
		_interactions[map_coord] = map_place
	return _interactions

func get_interaction(map_coord: Vector2i) -> MapPlace:
	return _interactions[map_coord]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("revisit"):
		on_player_move(_player.map_coord)

func on_player_move(map_coord: Vector2i) -> void:
	if map_coord in _interactions:
		$/root/MovementUI._stop_move()
		do_interaction(_interactions[map_coord])

	for map_entity in get_tree().get_nodes_in_group("MapEntities"):
		if map_entity is Wanderer:
			var wanderer = map_entity as Wanderer
			if map_coord == wanderer.map_coord:
				wanderer.do_interaction()
				$/root/MovementUI._stop_move()

func do_interaction(place: MapPlace) -> void:
	if place.is_pyramid and $/root/ArtifactsService.has_scarab_key:
		place.visited = true
		$/root/DialogMenu.show_dialog(place.win_dialog)
	elif !place.visited and place.dialog_deck != null:
		place.visited = true
		$/root/DialogMenu.show_dialog(place.dialog_deck.get_next_dialog())
	elif place.visited_dialog != null:
		$/root/DialogMenu.show_dialog(place.visited_dialog)

#places {
#	CAMP,
#	CAVE,
#	OASIS,
#	OBESLISK,
#	PYRAMID,
#	RUINS,
#	SKELETON,
#	TAR_PIT,
#	TEMPLE,
#	TOWER,
#	VILLAGE,
#}
#
#wanderers {
#	BANDIT,
#	SCORPION,
#	TRAVELER,
#	SCARAB,
#}
