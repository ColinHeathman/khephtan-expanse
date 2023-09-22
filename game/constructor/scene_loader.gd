extends Node

var game_scn = preload("res://game/game.tscn")
var next_frame_setup: int

func _ready() -> void:
	if has_node("/root/MainMenu"):
		$/root/InGameMenu.start.connect(self.show_stats_picker)
		$/root/InGameMenu.show()

func  _process(_delta: float) -> void:
	if next_frame_setup > 1:
		next_frame_setup -= 1
	if next_frame_setup == 1:
		do_setup()
		next_frame_setup = 0

func show_stats_picker() -> void:
	$/root/InGameMenu.start.disconnect(self.show_stats_picker)
	$/root/PlayerStatsPicker.show()
	$/root/PlayerStatsPicker.done.connect(self.done_picking_stats)

func done_picking_stats() -> void:
	$/root/MainMenu/LoadingDialog.show()
	$/root/PlayerStatsPicker.done.disconnect(self.done_picking_stats)
	$/root/PlayerStatsService._hit_points = $/root/PlayerStatsPicker.constitution
	$/root/PlayerStatsService._constitution = $/root/PlayerStatsPicker.constitution
	$/root/PlayerStatsService._wisdom = $/root/PlayerStatsPicker.wisdom
	$/root/PlayerStatsService._diplomacy = $/root/PlayerStatsPicker.diplomacy
	$/root/Hud.update_hud()
	game_start()

func game_start() -> void:
	var main = game_scn.instantiate()
	main.name = "Main"
	$/root.add_child(main)
	next_frame_setup = 5 # stupid hack

func do_setup() -> void:
	$/root/Constructor.setup()
	$/root/MainMenu/LoadingDialog.hide()
	$/root/MainMenu.queue_free()
