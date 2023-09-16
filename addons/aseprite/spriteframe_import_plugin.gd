@tool
class_name AsepriteSpriteframeImportPlugin
extends EditorImportPlugin

var _executable: AsepriteExecutable
var _editor: EditorInterface

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var err: Error = OK
	
	# Save empty SpriteFrames as fallback
	var sprite_frames_path = "%s.%s" % [save_path, _get_save_extension()]
	var sprite_frames = SpriteFrames.new()
	err = ResourceSaver.save(sprite_frames, sprite_frames_path)
	if err != OK:
		print("placeholder SpriteFrames save error: %s" % error_string(err))
		return err
	sprite_frames.take_over_path(sprite_frames_path)

	# Make textures folder if required
	var source_file_folder = source_file.rsplit("/", true, 1)[0]
	var source_file_basename = source_file.rsplit("/", true, 1)[1]
	var source_file_no_ext = source_file_basename.rsplit(".", true, 1)[0]
	var textures_folder = "%s/textures" % source_file_folder
	DirAccess.make_dir_recursive_absolute(textures_folder)

	# Execute Aseprite
	var aseprite_result = _executable.export_spritesheet(source_file, textures_folder, source_file_no_ext)
	if aseprite_result.error != null:
		print("Aseprite error: %s" % aseprite_result.error)
		return ERR_SCRIPT_FAILED
	
	# Unmarshal result
	var spritesheet_path = aseprite_result.spritesheet_path
	var spritesheet_data = aseprite_result.data
	_editor.get_resource_filesystem().scan_sources()
	var spritesheet_tex: Texture2D = ResourceLoader.load(spritesheet_path, "Texture2D", ResourceLoader.CACHE_MODE_REPLACE)
	if spritesheet_tex == null:
		print("Failed to load texture")
		return ERR_SCRIPT_FAILED

	# Get Array[AtlasTexture]
	var atlas_textures = AsepriteSpriteFrameTools.make_atlas_textures(spritesheet_tex, spritesheet_data)
	# Add each to SpriteFrames
	AsepriteSpriteFrameTools.add_animations_to_spriteframes(sprite_frames, spritesheet_data, atlas_textures)

	# Save result
	err = ResourceSaver.save(sprite_frames, sprite_frames_path)
	if err != OK:
		print("SpriteFrames save error: %s" % error_string(err))
		return err
	sprite_frames.take_over_path(sprite_frames_path)
	
	_editor.get_resource_filesystem().scan()

func _get_priority() -> float:
	return 3.0
	
func _get_import_order() -> int:
	return 0

func _get_importer_name() -> String:
	return "aseprite.spriteframes"

func _get_visible_name() -> String:
	return "SpriteFrames"

func _get_save_extension() -> String:
	return "tres"

func _get_resource_type() -> String:
	return "SpriteFrames"

enum Presets { DEFAULT }

const script_property = {
	"name": "aseprite_script",
	"default_value": "",
	"hint_string": "Runs the given Aseprite lua script before export",
	# "property_hint": "",
	# "usage": "",
}

func _get_recognized_extensions() -> PackedStringArray:
	return ["ase", "aseprite"]

func _get_preset_count() -> int:
	return Presets.size()

func _get_preset_name(preset_index) -> String:
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_import_options(path, preset_index) -> Array[Dictionary]:
	match preset_index:
		Presets.DEFAULT:
			return [script_property]
		_:
			return []

func _get_option_visibility(path, option_name, options):
	return true
