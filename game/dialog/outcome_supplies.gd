class_name OutcomeSupplies
extends OutcomeAction

@export var change = 0

func exec(menu: Node) -> bool:
	menu.get_node("/root/PlayerStatsService").supplies += change
	return true
