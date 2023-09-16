extends CanvasLayer

var _current_dialog: Dialog
var _rng: RandomNumberGenerator
var _pseudorandom: Psuedorandom

const heart_icon = preload("res://game/ui/menus/player_stats_picker/textures/heart_icon.tres")

signal dialog_visible(bool)

func _init() -> void:
	_rng = RandomNumberGenerator.new()
	var rng_deck: Array[int] = []
	for i in range(1, 20):
		rng_deck.append(i)
	_pseudorandom = Psuedorandom.new(rng_deck, 1, _rng.randi())

func _ready() -> void:
	%OKButton.pressed.connect(_on_ok)
	%ConstitutionCheckButton.pressed.connect(_constitution_check)
	%WisdomCheckButton.pressed.connect(_wisdom_check)
	%DiplomacyCheckButton.pressed.connect(_diplomacy_check)
	%CurrencyCheckButton.pressed.connect(_on_currency_check)
	self.visibility_changed.connect(signal_visibility)

func signal_visibility() -> void:
	dialog_visible.emit(self.visible)

func show_dialog(dialog: Dialog) -> void:
	_current_dialog = dialog
	%MessageLabel.text = dialog.message
	%MessageLabel.custom_minimum_size = Vector2(dialog.override_minimum_width, 0.0)
	_update_outcome_message(dialog)
	_update_bonus_message(dialog)
	_update_button(dialog.ok_message, %OKButton, null)
	_update_button(dialog.hit_points_message, %ConstitutionCheckButton, %ConstitutionCheckButtonLabel)
	_update_button(dialog.wisdom_message, %WisdomCheckButton, %WisdomCheckButtonLabel)
	_update_button(dialog.diplomacy_message, %DiplomacyCheckButton, %DiplomacyCheckButtonLabel)
	_update_button(dialog.currency_message, %CurrencyCheckButton, %CurrencyCheckButtonLabel)
	_update_constitution_cost_label(dialog)
	_update_chance_label($/root/PlayerStatsService.wisdom, dialog.wisdom_dc, %WisdomCheckButtonChanceLabel)
	_update_chance_label($/root/PlayerStatsService.diplomacy, dialog.diplomacy_dc, %DiplomacyCheckButtonChanceLabel)
	_update_currency_cost_label(dialog)
	_enable_disable_currency(dialog)
	self.show()

func _update_outcome_message(dialog: Dialog) -> void:
	%OutcomeLabel.text = dialog.outcome_label
	if dialog.outcome_label == "":
		%OutcomeLabel.hide()
		return
	%OutcomeLabel.add_theme_color_override("font_color", Dialog.get_outcome_color(dialog.outcome_color))
	%OutcomeLabel.show()

func _update_bonus_message(dialog: Dialog) -> void:
	if dialog.bonus_message != "":
		%BonusLabel.text = dialog.bonus_message
		%BonusLabel.show()
	else:
		%BonusLabel.hide()
	if dialog.bonus_icon != null:
		%BonusTextureRect.texture = dialog.bonus_icon
		%BonusTextureRect.reset_size()
		%BonusTextureRect.show()
	else:
		%BonusTextureRect.hide()

func _update_button(message: String, button: Button, label: Label) -> void:
	if message != "":
		if label != null:
			label.text = message
		else:
			button.text = message
		button.show()
	else:
		button.hide()

func _update_constitution_cost_label(dialog: Dialog) -> void:
	if dialog.hit_points_range.size() == 2:
		%ConstitutionCheckButtonCostLabel.text = "%s-%s" % dialog.hit_points_range
		%ConstitutionCheckButtonCostLabel.add_theme_color_override(
			"font_color",
			Dialog.get_outcome_color(Dialog.OutcomeColor.RED),
		)

func _update_chance_label(bonus: int, dc: int, label: Label) -> void:
	var chance = _difficulty_probability(bonus, dc)
	label.text = "%d%%" % chance
	if chance > 50:
		label.add_theme_color_override(
			"font_color",
			Dialog.get_outcome_color(Dialog.OutcomeColor.GREEN),
		)
	else:
		label.add_theme_color_override(
			"font_color",
			Dialog.get_outcome_color(Dialog.OutcomeColor.RED),
		)

func _update_currency_cost_label(dialog: Dialog) -> void:
	if dialog.currency_cost >= 0:
		%CurrencyCheckButtonCostLabel.text = "-%s" % dialog.currency_cost
		%CurrencyCheckButtonCostLabel.add_theme_color_override(
			"font_color",
			Dialog.get_outcome_color(Dialog.OutcomeColor.RED),
		)
	else:
		%CurrencyCheckButtonCostLabel.text = "+%s" % dialog.currency_cost
		%CurrencyCheckButtonCostLabel.add_theme_color_override(
			"font_color",
			Dialog.get_outcome_color(Dialog.OutcomeColor.GREEN),
		)

func _enable_disable_currency(dialog: Dialog) -> void:
	if dialog.currency_cost > $/root/PlayerStatsService.currency:
		%CurrencyCheckButton.disabled = true
	else:
		%CurrencyCheckButton.disabled = false

func _on_ok() -> void:
	_do_outcome(_current_dialog.ok_outcome)

func _constitution_check() -> void:
	var low_damage = _current_dialog.hit_points_range[0]
	var high_damage = _current_dialog.hit_points_range[1]
	var damage = _rng.randi_range(low_damage, high_damage)
	if _current_dialog.hit_points_outcome is Dialog:
		var new_dialog = _current_dialog.hit_points_outcome.duplicate()
		if new_dialog.bonus_icon == null:
			new_dialog.bonus_icon = heart_icon
			new_dialog.bonus_message = "-%s" % damage
		var outcome_damage = OutcomeDamage.new()
		outcome_damage.damage = damage
		if new_dialog.ok_outcome != null:
			outcome_damage.next_outcome = new_dialog.ok_outcome
		new_dialog.ok_outcome = outcome_damage
		self.show_dialog(new_dialog)

func _wisdom_check() -> void:
	if _difficulty_roll($/root/PlayerStatsService.wisdom, _current_dialog.wisdom_dc):
		if _current_dialog.wisdom_pass is Dialog:
			var new_dialog = _current_dialog.wisdom_pass
			if new_dialog.outcome_label == "":
				new_dialog = new_dialog.duplicate()
				new_dialog.outcome_label = "SUCCESS!"
				new_dialog.outcome_color = Dialog.OutcomeColor.GREEN
			self.show_dialog(new_dialog)
		else:
			self.hide()
			
	else:
		if _current_dialog.wisdom_fail is Dialog:
			var new_dialog = _current_dialog.wisdom_fail
			if new_dialog.outcome_label == "":
				new_dialog = new_dialog.duplicate()
				new_dialog.outcome_label = "FAIL!"
				new_dialog.outcome_color = Dialog.OutcomeColor.RED
			self.show_dialog(new_dialog)
		else:
			self.hide()

func _diplomacy_check() -> void:
	if _difficulty_roll($/root/PlayerStatsService.diplomacy, _current_dialog.diplomacy_dc):
		if _current_dialog.diplomacy_pass is Dialog:
			var new_dialog = _current_dialog.diplomacy_pass
			if new_dialog.outcome_label == "":
				new_dialog = new_dialog.duplicate()
				new_dialog.outcome_label = "SUCCESS!"
				new_dialog.outcome_color = Dialog.OutcomeColor.GREEN
			self.show_dialog(new_dialog)
		else:
			self.hide()

	else:
		if _current_dialog.diplomacy_fail is Dialog:
			var new_dialog = _current_dialog.diplomacy_fail
			if new_dialog.outcome_label == "":
				new_dialog = new_dialog.duplicate()
				new_dialog.outcome_label = "FAIL!"
				new_dialog.outcome_color = Dialog.OutcomeColor.RED
			self.show_dialog(new_dialog)
		else:
			self.hide()

func _difficulty_roll(bonus: int, dc: int) -> bool:
	var roll = _pseudorandom.get_random_item()
	var result = roll + bonus >= dc
	if result:
		print("PASS %d+%d >= %d" % [roll, bonus, dc])
	else:
		print("FAIL %d+%d >= %d" % [roll, bonus, dc])
	return result

func _difficulty_probability(bonus: int, dc: int) -> float:
	var chances_of_failure = float(dc - 1 - bonus)
	var p_fail = chances_of_failure / 20.0
	var p_success = 1.0 - p_fail
	var percent = min(100.0, max(0.0, p_success * 100.0))
	return percent

func _on_currency_check() -> void:
	var outcome_currency = OutcomeCurrency.new()
	outcome_currency.cost = _current_dialog.currency_cost
	outcome_currency.next_outcome = _current_dialog.currency_outcome
	_execute_actions(outcome_currency)

func _do_outcome(outcome: DialogOutcome) -> void:
	if outcome is Dialog:
		self.show_dialog(outcome)
	elif outcome is OutcomeAction:
		_execute_actions(outcome)
	else:
		self.hide()

func _execute_actions(action: OutcomeAction) -> void:
	var dialog_outcome: DialogOutcome = action
	self.hide()
	while true:
		if not dialog_outcome.exec(self): # continue?
			return
		dialog_outcome = dialog_outcome.next_outcome
		if !dialog_outcome is OutcomeAction:
			break
	if dialog_outcome is Dialog:
		self.show_dialog(action.next_outcome)
