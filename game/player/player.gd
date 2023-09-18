class_name Player
extends MapEntity

func get_vision_radius() -> int:
	var night_radius = 4
	var day_radius = 6
	if $/root/ArtifactsService.has_lantern:
		night_radius += 1
	if $/root/ArtifactsService.has_spyglass:
		day_radius += 2
	return night_radius if $"/root/TurnController".is_night else day_radius

func transition_to_day():
	%TorchAnimationPlayer.play("sunrise")

func transition_to_night():
	%TorchAnimationPlayer.play("sunset")

func move_to_coord(new_map_coord: Vector2i) -> void:
	super.move_to_coord(new_map_coord)
	%MoveAnimationPlayer.play("bounce")
