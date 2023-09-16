extends CanvasLayer

signal next_turn

func _on_end_turn_button_pressed() -> void:
	next_turn.emit()

func set_disabled(disabled: bool) -> void:
	%EndTurnButton.disabled = disabled

func set_turn(turn_number: int) -> void:
	%TurnLabel.text = "Turn %d" % turn_number

func update_supplies() -> void:
	%SuppliesLabel.text = "Supplies %d" % $/root/PlayerStatsService.supplies
