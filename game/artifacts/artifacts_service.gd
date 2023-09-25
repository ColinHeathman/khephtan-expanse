extends CanvasLayer

var has_civic_crown = false:
	get:
		return has_civic_crown
	set(value):
		if value and not has_civic_crown:
			$/root/PlayerStatsService.diplomacy += 2
		has_civic_crown = value
		if has_civic_crown:
			%CivicCrownPanel.show()
			self.show()
			
		else:
			%CivicCrownPanel.hide()

var has_scimitar = false:
	get:
		return has_scimitar
	set(value):
		has_scimitar = value
		if has_scimitar:
			%ScimitarPanel.show()
			self.show()
		else:
			%ScimitarPanel.hide()

var has_lantern = false:
	get:
		return has_lantern
	set(value):
		has_lantern = value
		if has_lantern:
			%LanternPanel.show()
			self.show()
		else:
			%LanternPanel.hide()

var has_spyglass = false:
	get:
		return has_spyglass
	set(value):
		has_spyglass = value
		if has_spyglass:
			%SpyglassPanel.show()
			self.show()
		else:
			%SpyglassPanel.hide()

var has_scepter = false:
	get:
		return has_scepter
	set(value):
		if value and not has_scepter:
			$/root/PlayerStatsService.wisdom += 2
		has_scepter = value
		if has_scepter:
			%ScepterPanel.show()
			self.show()
		else:
			%ScepterPanel.hide()

var has_scarab_key = false:
	get:
		return has_scarab_key
	set(value):
		has_scarab_key = value
		if has_scarab_key:
			%ScarabKeyPanel.show()
			self.show()
		else:
			%ScarabKeyPanel.hide()

func _ready() -> void:
	%CivicCrownPanel.mouse_entered.connect(_show_tooltip.bind(%CivicCrownTooltip))
	%CivicCrownPanel.mouse_exited.connect(_hide_tooltip.bind(%CivicCrownTooltip))
	%ScimitarPanel.mouse_entered.connect(_show_tooltip.bind(%ScimitarTooltip))
	%ScimitarPanel.mouse_exited.connect(_hide_tooltip.bind(%ScimitarTooltip))
	%LanternPanel.mouse_entered.connect(_show_tooltip.bind(%LanternTooltip))
	%LanternPanel.mouse_exited.connect(_hide_tooltip.bind(%LanternTooltip))
	%SpyglassPanel.mouse_entered.connect(_show_tooltip.bind(%SpyglassTooltip))
	%SpyglassPanel.mouse_exited.connect(_hide_tooltip.bind(%SpyglassTooltip))
	%ScepterPanel.mouse_entered.connect(_show_tooltip.bind(%ScepterTooltip))
	%ScepterPanel.mouse_exited.connect(_hide_tooltip.bind(%ScepterTooltip))
	%ScarabKeyPanel.mouse_entered.connect(_show_tooltip.bind(%ScarabKeyTooltip))
	%ScarabKeyPanel.mouse_exited.connect(_hide_tooltip.bind(%ScarabKeyTooltip))
	self.add_to_group("Resettable")

func _show_tooltip(tooltip: Node2D) -> void:
	tooltip.show()

func _hide_tooltip(tooltip: Node2D) -> void:
	tooltip.hide()

func on_game_reset():
	self.has_civic_crown = false
	self.has_scimitar = false
	self.has_lantern = false
	self.has_spyglass = false
	self.has_scepter = false
	self.has_scarab_key = false
	self.hide()
