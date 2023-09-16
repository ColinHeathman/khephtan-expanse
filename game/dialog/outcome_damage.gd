class_name OutcomeDamage
extends OutcomeAction

@export var damage = 0

func exec(menu: Node) -> bool:
	menu.get_node("/root/PlayerStatsService").hit_points -= damage
	if menu.get_node("/root/PlayerStatsService").hit_points > 0:
		return true
	else:
		return false
