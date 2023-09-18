class_name OutcomeDamage
extends OutcomeAction

@export var damage = 0

func exec(menu: Node) -> bool:
	var stats = menu.get_node("/root/PlayerStatsService")
	stats.hit_points = min(stats.hit_points - damage, stats._constitution)
	if stats.hit_points > 0:
		return true
	else:
		return false
