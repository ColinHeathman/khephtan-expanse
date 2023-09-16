class_name OutcomeCurrency
extends OutcomeAction

@export var cost = 0

func exec(menu: Node) -> bool:
	menu.get_node("/root/PlayerStatsService").currency -= cost
	return true
