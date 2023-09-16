extends Camera2D

signal zoom_changed()
signal moved()

const ZOOM_INCREMENT = 0.25
const ZOOM_MIN = 0.25
const ZOOM_MAX = 4
const SPEED = 1000.0

var _velocity: Vector2

func _process(delta: float) -> void:
	if _velocity != Vector2():
		self.position += _velocity * delta
		moved.emit()

func _input(event: InputEvent) -> void:
	if event.is_action("debug_camera_left"):
		_velocity.x = -SPEED * event.get_action_strength("debug_camera_left")
		get_viewport().set_input_as_handled()
	if event.is_action("debug_camera_right"):
		_velocity.x = SPEED * event.get_action_strength("debug_camera_right")
		get_viewport().set_input_as_handled()
	if event.is_action("debug_camera_up"):
		_velocity.y = -SPEED * event.get_action_strength("debug_camera_up")
		get_viewport().set_input_as_handled()
	if event.is_action("debug_camera_down"):
		_velocity.y = SPEED * event.get_action_strength("debug_camera_down")
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("zoom_in"):
		if self.zoom.x < ZOOM_MAX:
			self.zoom.x += ZOOM_INCREMENT
			self.zoom.y += ZOOM_INCREMENT
			get_viewport().set_input_as_handled()
			zoom_changed.emit()

	if event.is_action_pressed("zoom_out"):
		if self.zoom.x > ZOOM_MIN:
			self.zoom.x -= ZOOM_INCREMENT
			self.zoom.y -= ZOOM_INCREMENT
			get_viewport().set_input_as_handled()
			zoom_changed.emit()
