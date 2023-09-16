@tool
class_name AsepriteTextureImportPlugin
extends EditorImportPlugin

var _executable: AsepriteExecutable
var _editor: EditorInterface

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var err: Error = OK
	
	# Save empty AtlasTexture as fallback
	var texture_path = "%s.%s" % [save_path, _get_save_extension()]
	var atex = AtlasTexture.new()
	err = ResourceSaver.save(atex, texture_path)
	if err != OK:
		print("AtlasTexture save error: %s" % error_string(err))
		return err
	atex.take_over_path(texture_path)

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
	# _editor.get_resource_filesystem().scan()
	# self.append_import_external_resource(spritesheet_path)
	var spritesheet_tex: Texture2D = ResourceLoader.load(spritesheet_path, "Texture2D", ResourceLoader.CACHE_MODE_REPLACE)
	if spritesheet_tex == null:
		print("Failed to load texture")
		return ERR_SCRIPT_FAILED
		
	if options.generate_atlas_textures:
		# Get Atlas Textures
		var atlas_textures = AsepriteAtlasTools.make_or_load_named_atlas_textures(spritesheet_tex, spritesheet_data, source_file_folder)
		# Save texture .tres files to resources
		AsepriteAtlasTools.save_named_atlas_textures(atlas_textures, source_file, source_file_folder)

		# Get Styleboxes
		var styleboxes = AsepriteAtlasTools.make_or_load_named_styleboxes(atlas_textures, spritesheet_data, source_file_folder)
		# Save styleboxes .tres files to resources
		AsepriteAtlasTools.save_named_styleboxes(styleboxes, source_file, source_file_folder)

	atex.atlas = spritesheet_tex
	atex.region.position.x = 0
	atex.region.position.y = 0
	atex.region.size.x = spritesheet_tex.get_width()
	atex.region.size.y = spritesheet_tex.get_height()
	err = ResourceSaver.save(atex, texture_path)
	if err != OK:
		print("AtlasTexture save error: %s" % error_string(err))
		return err

	_editor.get_resource_filesystem().scan()

func _get_priority() -> float:
	return 5.0
	
func _get_import_order() -> int:
	return 0

func _get_importer_name() -> String:
	return "aseprite.texture"

func _get_visible_name() -> String:
	return "AtlasTexture"

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "AtlasTexture"

enum Presets { DEFAULT }

const script_property = {
	"name": "aseprite_script",
	"default_value": "",
	"hint_string": "Runs the given Aseprite lua script before export",
	# "property_hint": "",
	# "usage": "",
}

const generate_atlases = {
	"name": "generate_atlas_textures",
	"default_value": false,
	"hint_string": "Generate Atlas Texture resources",
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
			return [script_property, generate_atlases]
		_:
			return []

func _get_option_visibility(path, option_name, options):
	return true
