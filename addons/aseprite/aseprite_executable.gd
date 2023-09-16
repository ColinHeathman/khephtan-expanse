@tool
class_name AsepriteExecutable
extends RefCounted

var _config: AsepriteConfig

func export_spritesheet(source_file, save_folder, save_name) -> Dictionary:
	
	var spritesheet_path: String = "%s/%s_spritesheet.png" % [save_folder, save_name]
	var datafile_path: String = "%s/%s_data.json" % [save_folder, save_name]
	
	# Result dict
	var result = {
		"spritesheet_path": spritesheet_path,
		"data": null,
		"error": null,
	}
	
	# Export from Aseprite
	var absolute_source_file: String = ProjectSettings.globalize_path(source_file)
	var absolute_spritesheet_path: String = ProjectSettings.globalize_path(spritesheet_path)
	var absolute_datafile_path: String = ProjectSettings.globalize_path(datafile_path)
	
	# Aseprite arguments
	var args = ["--batch", "--list-layers", "--list-tags", "--list-slices"] 
	args += ["--sheet", absolute_spritesheet_path]
	args += ["--data", absolute_datafile_path]
	args += [absolute_source_file]
	
	# Execute Aseprite and capture stdout, stderr
	var output: Array = []
	var exit_code = OS.execute(_config.get_aseprite_cmd(), args, output, true)
	if exit_code != OK:
		result.error = output[0]
		return result
	
	# Load spritesheet as image
	#	result.spritesheet = Image.new()
	#	var err = result.spritesheet.load(spritesheet_path)
	#	if err != OK:
	#		result.error = "image load error: %s" % error_string(err)
	#		return result
	
	# Load spritesheet data
	result.data = JSON.parse_string(FileAccess.get_file_as_string(datafile_path))
	
	# Discard PNG file and JSON file
#	DirAccess.remove_absolute(spritesheet_path)
#	DirAccess.remove_absolute(datafile_path)
	
	return result
