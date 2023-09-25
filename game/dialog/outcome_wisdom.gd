class_name OutcomeWisdom
extends OutcomeAction

@export var change = 0

func exec(menu: Node) -> bool:
	menu.get_node("/root/PlayerStatsService").wisdom += change
	return true
