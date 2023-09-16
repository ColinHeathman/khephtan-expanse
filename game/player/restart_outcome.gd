class_name OutcomeActionRestart
extends OutcomeAction

func exec(menu: Node) -> bool:
	menu.get_node("/root/InGameMenu").restart.emit()
	return false
