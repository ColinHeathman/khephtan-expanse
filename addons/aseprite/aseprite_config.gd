@tool
class_name AsepriteConfig
extends RefCounted

const command_key = "aseprite/general/command_path"
const command_default_value = "aseprite"

var _editor_settings: EditorSettings

func setup_editor_settings() -> void:
	if not _editor_settings.has_setting(command_key):
		_editor_settings.set_initial_value(command_key, command_default_value, false)
		_editor_settings.add_property_info({
			"name": command_key,
			"type": TYPE_STRING,
			"hint": "Path to aseprite executable",
		})


func get_aseprite_cmd() -> String:
	if _editor_settings.has_setting(command_key):
		return _editor_settings.get(command_key)
	else:
		return "aseprite"

