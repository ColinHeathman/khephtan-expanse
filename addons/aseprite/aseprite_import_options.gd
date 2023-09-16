@tool
class_name AsepriteImportOptions
extends RefCounted

enum Presets { DEFAULT }


const loop_animation_property = {
	"name": "aseprite_script",
	"default_value": "",
	"hint_string": "Runs the given Aseprite lua script before export",
	# "property_hint": "",
	# "usage": "",
}

static func get_recognized_extensions() -> PackedStringArray:
	return ["ase", "aseprite"]

static func get_preset_count() -> int:
	return Presets.size()

static func get_preset_name(preset_index) -> String:
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

static func get_import_options(path, preset_index) -> Array[Dictionary]:
	match preset_index:
		Presets.DEFAULT:
			return [loop_animation_property]
		_:
			return []

static func get_option_visibility(path, option_name, options):
	return true
