extends CanvasLayer

var constitution = 10
var wisdom = 5
var diplomacy = 5
var extra_points = 5

signal done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ConstitutionSpinBox.value_changed.connect(self._on_constitution_spin_box_value_changed)
	%WisdomSpinBox.value_changed.connect(self._on_wisdom_spin_box_value_changed)
	%DiplomacySpinBox.value_changed.connect(self._on_diplomacy_spin_box_value_changed)
	%OKButton.pressed.connect(self._done)
	
func _done() -> void:
	self.hide()
	done.emit()

func _on_constitution_spin_box_value_changed(value: float) -> void:
	var i_value = int(value)
	var cost = i_value - constitution
	constitution = value
	extra_points -= cost
	_update_maximums()

func _on_wisdom_spin_box_value_changed(value: float) -> void:
	var i_value = int(value)
	var cost = i_value - wisdom
	wisdom = value
	extra_points -= cost
	_update_maximums()

func _on_diplomacy_spin_box_value_changed(value: float) -> void:
	var i_value = int(value)
	var cost = i_value - diplomacy
	diplomacy = value
	extra_points -= cost
	_update_maximums()

func _update_maximums() -> void:
	%ConstitutionSpinBox.max_value = %ConstitutionSpinBox.value + extra_points
	%WisdomSpinBox.max_value = %WisdomSpinBox.value + extra_points
	%DiplomacySpinBox.max_value = %DiplomacySpinBox.value + extra_points
	if extra_points > 0:
		%ExtraPointLabel.text = "+%s" % extra_points
	else:
		%ExtraPointLabel.text = "%s" % extra_points
