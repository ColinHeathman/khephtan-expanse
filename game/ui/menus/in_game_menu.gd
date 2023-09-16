extends CanvasLayer

signal start
signal restart

@onready var AUDIO_BUS_MUSIC = AudioServer.get_bus_index("Music")
@onready var AUDIO_BUS_FX = AudioServer.get_bus_index("FX")

var controls_shown = false
var showing_controls_anyways = false

func _ready() -> void:
	# Show default view
	_show_main()
	%RestartButton.hide()
	
	# Configure audio
	assert(AUDIO_BUS_MUSIC > 0)
	assert(AUDIO_BUS_FX > 0)
	AudioServer.set_bus_mute(AUDIO_BUS_MUSIC, false)
	AudioServer.set_bus_volume_db(AUDIO_BUS_MUSIC, _lerp_DB_Volume(50))
	AudioServer.set_bus_mute(AUDIO_BUS_FX, false)
	AudioServer.set_bus_volume_db(AUDIO_BUS_FX, _lerp_DB_Volume(50))
	
	# Connect signals
	%MusicSlider.connect("value_changed", self._on_music_slider_value_changed)
	%FXSlider.connect("value_changed", self._on_fx_slider_value_changed)
	%CreditsButton.connect("pressed", self._show_credits)
	%StartButton.connect("pressed", self._on_start_button_pressed)
	%RestartButton.connect("pressed", self._on_restart_button_pressed)
	%CreditsOKButton.connect("pressed", self._show_main)
	%ControlsButton.connect("pressed", self._show_controls)
	%ControlsOKButton.connect("pressed", self._on_controls_ok_button_pressed)

func _show_main() -> void:
	%CreditsView.hide()
	%ControlsView.hide()
	%DefaultView.show()

func _show_controls() -> void:
	controls_shown = true
	%CreditsView.hide()
	%ControlsView.show()
	%DefaultView.hide()

func _show_credits() -> void:
	%CreditsView.show()
	%ControlsView.hide()
	%DefaultView.hide()

func _input(event: InputEvent) -> void:
	# toggle menu
	if event.is_action_pressed("show_menu"):
		if self.visible:
			_on_start_button_pressed()
		elif $/root/Main:
			_show_main()
			self.show()
		# consume event
		get_viewport().set_input_as_handled()

func _on_start_button_pressed() -> void:
	if !controls_shown:
		showing_controls_anyways = true
		_show_controls()
		return
	_show_main()
	self.hide()
	self.start.emit()
	%StartButton.text = "Resume"
	%RestartButton.show()

func _on_restart_button_pressed() -> void:
	_show_main()
	self.hide()
	self.restart.emit()

func _on_controls_ok_button_pressed() -> void:
	if showing_controls_anyways:
		_on_start_button_pressed()
	else:
		_show_main()

func _on_music_slider_value_changed(value) -> void:
	if value == 0:
		AudioServer.set_bus_mute(AUDIO_BUS_MUSIC, true)
	else:
		AudioServer.set_bus_mute(AUDIO_BUS_MUSIC, false)
		AudioServer.set_bus_volume_db(AUDIO_BUS_MUSIC, _lerp_DB_Volume(value))

func _on_fx_slider_value_changed(value) -> void:
	if value == 0:
		AudioServer.set_bus_mute(AUDIO_BUS_FX, true)
	else:
		AudioServer.set_bus_mute(AUDIO_BUS_FX, false)
		AudioServer.set_bus_volume_db(AUDIO_BUS_FX, _lerp_DB_Volume(value))
	if %ReferenceTick/Debouncer.is_stopped():
		%ReferenceTick.play()
		%ReferenceTick/Debouncer.start()

func _lerp_DB_Volume(value) -> float:
	return (value * 18.0 / 100.0) - 9.0
