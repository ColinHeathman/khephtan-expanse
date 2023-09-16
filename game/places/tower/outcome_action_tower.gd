class_name OutcomeActionTower
extends OutcomeAction

@export var day_radius = 16
@export var night_radius = 12

func exec(_menu: Node) -> bool:
	var radius = day_radius
	if _menu.get_node("/root/TurnController").is_night:
		radius = night_radius
	var map_coord = _menu.get_node("/root/Main/Player").map_coord
	_menu.get_node("/root/FogOfWar").reveal_around_point(map_coord, radius)
	return true
