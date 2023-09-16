extends Node

signal new_turn(int)
signal daytime
signal nightime

var turn_count = 0
var is_night = false

func _ready() -> void:
	self.add_to_group("Resettable")

func next_turn() -> void:
	turn_count += 1
	if turn_count % 2 == 1:
		nightime.emit()
		is_night = true
		self.call_deferred("transition_to_night")
	else:
		daytime.emit()
		is_night = false
		self.call_deferred("transition_to_day")
	new_turn.emit(turn_count)

const OPAQUE = Color(1.0,1.0,1.0,1.0)
const PARTIALLY_TRANSPARENT = Color(1.0,1.0,1.0,0.5)
const TRANSPARENT = Color(1.0,1.0,1.0,0.0)

func transition_to_day() -> void:
	for node in get_tree().get_nodes_in_group("Lights"):
		var t = node.create_tween()
		t.tween_property(node, "modulate", TRANSPARENT, 1.0)
	for node in get_tree().get_nodes_in_group("Shadows"):
		var t = node.create_tween()
		t.tween_property(node, "modulate", PARTIALLY_TRANSPARENT, 1.0)
		t.tween_property(node, "modulate", OPAQUE, 1.0)

func transition_to_night() -> void:
	for node in get_tree().get_nodes_in_group("Shadows"):
		var t = node.create_tween()
		t.tween_property(node, "modulate", PARTIALLY_TRANSPARENT, 1.0)
	for node in get_tree().get_nodes_in_group("Lights"):
		var t = node.create_tween()
		t.tween_property(node, "modulate", TRANSPARENT, 1.0)
		t.tween_property(node, "modulate", OPAQUE, 1.0)

func on_game_reset() -> void:
	turn_count = 0
	daytime.emit()
	is_night = false
	self.call_deferred("transition_to_day")
