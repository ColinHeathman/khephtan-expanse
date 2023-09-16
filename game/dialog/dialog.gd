class_name Dialog
extends DialogOutcome

enum OutcomeColor {
	GREEN,
	RED,
	WHITE,
}

@export var override_minimum_width: int = 0
@export var outcome_label: String
@export var outcome_color: OutcomeColor
@export_multiline var message: String
@export var bonus_message: String
@export var bonus_icon: Texture2D

@export_category("OK")
@export_multiline var ok_message: String
@export var ok_outcome: DialogOutcome

@export_category("Constitution")
@export var hit_points_range: Array[int] = []
@export_multiline var hit_points_message: String
@export var hit_points_outcome: Dialog

@export_category("Wisdom")
@export var wisdom_dc: int = 0
@export_multiline var wisdom_message: String
@export var wisdom_pass: Dialog
@export var wisdom_fail: Dialog

@export_category("Diplomacy")
@export var diplomacy_dc: int = 0
@export_multiline var diplomacy_message: String
@export var diplomacy_pass: Dialog
@export var diplomacy_fail: Dialog

@export_category("Currency")
@export var currency_cost: int = 0
@export_multiline var currency_message: String
@export var currency_outcome: DialogOutcome

static func get_outcome_color(color: OutcomeColor) -> Color:
	if color == OutcomeColor.GREEN:
		return Color(0.0,0.75,0.0,1.0)
	if color == OutcomeColor.RED:
		return Color(0.75,0.0,0.0,1.0)
	return Color(1.0,1.0,1.0,1.0)
