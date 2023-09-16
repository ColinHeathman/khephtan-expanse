extends CanvasLayer

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
