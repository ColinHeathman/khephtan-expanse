class_name Psuedorandom
extends RefCounted

var _index : int
var _deck : Array[Variant]
var _rng : RandomNumberGenerator

func _init(deck : Array, deck_multiplier : int, rng_seed: int = 0):
	_index = 0

	for i in range(deck_multiplier):
		_deck.append_array(deck)
	
	_rng = RandomNumberGenerator.new()
	if rng_seed != 0:
		_rng.seed = rng_seed
	_shuffle()

func _shuffle():
	for i in range(len(_deck) * 1):
		var x = _rng.randi() % _deck.size()
		var y = _rng.randi() % _deck.size()
		_swap(x, y)

func _swap(x, y):
	var swap = _deck[x]
	_deck[x] = _deck[y]
	_deck[y] = swap

func size() -> int:
	return _deck.size()

func get_random_item() -> Variant:
	if _index >= _deck.size():
		_index = 0
		_shuffle()
	var item = _deck[_index]
	_index += 1
	return item

func extract_first_matching_item(query: Array) -> Variant:
	if _index >= _deck.size():
		_index = 0
		_shuffle()
	
	for i in range(_index, _deck.size(), 1):
		if query.has(_deck[i]):
			var item = _deck[i]
			_swap(_index, i)
			_index += 1
			return item

	for i in range(0, _index, 1):
		if query.has(_deck[i]):
			var item = _deck[i]
			_swap(_index, i)
			_index += 1
			return item
	
	print("Could not find matching item")
	assert(false)
	return null
