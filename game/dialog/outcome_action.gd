class_name OutcomeAction
extends DialogOutcome

@export var next_outcome: DialogOutcome

func exec(_menu: Node) -> bool:
	return true
