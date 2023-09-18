extends Node

const player_death_dialog = preload("res://game/player/player_death_dialog.tres")
const player_start_dialog = preload("res://game/player/player_start_dialog.tres")
const low_supplies_dialog = preload("res://game/player/no_supplies_dialog/low_supplies_dialog.tres")
const no_supplies_dialog = preload("res://game/player/no_supplies_dialog/no_supplies_dialog.tres")


signal constitution_changed
signal hit_points_changed
signal wisdom_changed
signal diplomacy_changed
signal currency_changed
signal supplies_changed

var _constitution: int
var constitution: int:
	get:
		return _constitution
	set(value):
		_constitution = value
		constitution_changed.emit()

var _hit_points: int
var hit_points: int:
	get:
		return _hit_points
	set(value):
		_hit_points = value
		hit_points_changed.emit()

var _wisdom: int
var wisdom: int:
	get:
		return _wisdom
	set(value):
		_wisdom = value
		wisdom_changed.emit()

var _diplomacy: int
var diplomacy: int:
	get:
		return _diplomacy
	set(value):
		_diplomacy = value
		diplomacy_changed.emit()

var _currency: int
var currency: int:
	get:
		return _currency
	set(value):
		_currency = max(0, value)
		currency_changed.emit()

var _supplies: int
var supplies: int:
	get:
		return _supplies
	set(value):
		_supplies = max(0, value)
		supplies_changed.emit()

var low_supplies_warning = 0

func _ready() -> void:
	_constitution = 10
	_hit_points = 10
	_wisdom = 5
	_diplomacy = 5
	_currency = 5
	_supplies = 0
	self.hit_points_changed.connect(_on_hitpoints_changed)
	self.add_to_group("Resettable")

func _on_hitpoints_changed() -> void:
	if hit_points <= 0:
		$/root/DialogMenu.show_dialog(player_death_dialog)

func on_next_turn() -> void:
	if supplies <= 0:
		if low_supplies_warning == 0:
			$/root/DialogMenu.show_dialog(low_supplies_dialog)
			low_supplies_warning += 1
		elif low_supplies_warning < 2:
			low_supplies_warning += 1
		else:
			$/root/DialogMenu.show_dialog(no_supplies_dialog)
	else:
		supplies -= 1

func on_game_reset() -> void:
	low_supplies_warning = 0
	hit_points = constitution
	supplies = 0
