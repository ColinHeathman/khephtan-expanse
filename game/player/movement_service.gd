extends Node

var move_points_per_turn: float = 30.0
var move_points_remaining: float = 0.0

signal move_points_changed(float)

func _init() -> void:
	reset_move_points()

func subtract_move_points(points: float) -> void:
	move_points_remaining -= points
	move_points_changed.emit(move_points_remaining)

func reset_move_points() -> void:
	move_points_remaining = move_points_per_turn
	move_points_changed.emit(move_points_remaining)
