class_name DialogDeck
extends Resource

@export var dialogs: Array[Dialog]

var _psuedorandom: Psuedorandom

func _get_deck_lazy() -> Psuedorandom:
	if _psuedorandom == null:
		_psuedorandom = Psuedorandom.new(range(0, dialogs.size()), 1)
	return _psuedorandom

func get_next_dialog() -> Dialog:
	return dialogs[_get_deck_lazy().get_random_item()]
