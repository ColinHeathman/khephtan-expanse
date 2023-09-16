class_name Player
extends MapEntity

func get_vision_radius() -> int:
	return 4 if $"/root/TurnController".is_night else 6

func transition_to_day():
	%TorchAnimationPlayer.play("sunrise")

func transition_to_night():
	%TorchAnimationPlayer.play("sunset")

func move_to_coord(new_map_coord: Vector2i) -> void:
	super.move_to_coord(new_map_coord)
	%MoveAnimationPlayer.play("bounce")
