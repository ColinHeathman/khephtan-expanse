extends Node

func transition_to_day():
	%AnimationPlayer.play("sunrise")

func transition_to_night():
	%AnimationPlayer.play("sunset")
