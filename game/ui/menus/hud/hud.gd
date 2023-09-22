extends CanvasLayer

func _ready() -> void:
	%SettingsButton.pressed.connect(_show_in_game_menu)
	
func _show_in_game_menu() -> void:
	var show_menu_event = InputEventAction.new()
	show_menu_event.action = "show_menu"
	show_menu_event.pressed = true
	Input.parse_input_event(show_menu_event)

func update_hud() -> void:
	update_hit_points()
	update_wisdom()
	update_diplomacy()
	update_currency()

func update_hit_points() -> void:
	%HitPointsAmount.text = "%s/%s" % [$/root/PlayerStatsService.hit_points, $/root/PlayerStatsService.constitution]

func update_wisdom() -> void:
	%WisdomAmount.text = "%s" % $/root/PlayerStatsService.wisdom

func update_diplomacy() -> void:
	%DiplomacyAmount.text = "%s" % $/root/PlayerStatsService.diplomacy

func update_currency() -> void:
	%CurrencyAmount.text = "%s" % $/root/PlayerStatsService.currency
