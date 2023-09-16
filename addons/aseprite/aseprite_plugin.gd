@tool
class_name AsepritePlugin
extends EditorPlugin

var texture_import_plugin : AsepriteTextureImportPlugin
var spriteframe_import_plugin : AsepriteSpriteframeImportPlugin
var config : AsepriteConfig
var executable : AsepriteExecutable

func _enter_tree():
	var editor = get_editor_interface()
	
	# Configuration
	config = AsepriteConfig.new()
	config._editor_settings = editor.get_editor_settings()
	config.setup_editor_settings()
	
	# Executable
	executable = AsepriteExecutable.new()
	executable._config = config
	
	# Texture2D Importer
	texture_import_plugin = AsepriteTextureImportPlugin.new()
	texture_import_plugin._editor = editor
	texture_import_plugin._executable = executable
	add_import_plugin(texture_import_plugin)

	# SpriteFrames Importer
	spriteframe_import_plugin = AsepriteSpriteframeImportPlugin.new()
	spriteframe_import_plugin._editor = editor
	spriteframe_import_plugin._executable = executable
	add_import_plugin(spriteframe_import_plugin)

func _exit_tree():
	remove_import_plugin(texture_import_plugin)
	remove_import_plugin(spriteframe_import_plugin)
