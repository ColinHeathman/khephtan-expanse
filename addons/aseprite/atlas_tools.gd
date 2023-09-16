@tool
class_name AsepriteAtlasTools
extends RefCounted

static func make_or_load_named_atlas_textures(tex: Texture2D, spritesheet_data: Dictionary, source_file_folder: String) -> Dictionary:
	
	# Result
	var atlas_textures: Dictionary = {}
		
	# Make atlas textures
	for slice in spritesheet_data.meta.slices:
		var name: String = slice.name
		if name.ends_with("-noimp"):
			continue

		# Make or load AtlasTexture
		var atlas_texture_path: String = "%s/textures/%s.tres" % [source_file_folder, name]
		var atex: AtlasTexture
		if FileAccess.file_exists(atlas_texture_path):
			atex = load(atlas_texture_path)
		else:
			atex = AtlasTexture.new()
		
		atex.atlas = tex
		atex.region.position.x = slice.keys[0].bounds.x
		atex.region.position.y = slice.keys[0].bounds.y
		atex.region.size.x = slice.keys[0].bounds.w
		atex.region.size.y = slice.keys[0].bounds.h
		atlas_textures[name] = atex
		
	return atlas_textures

static func save_named_atlas_textures(atlas_textures: Dictionary, source_file: String, source_file_folder: String) -> Error:
	
	# Save each entry as an atlas texture
	for name in atlas_textures:
		var atlas_texture_path: String = "%s/textures/%s.tres" % [source_file_folder, name]
		var err = ResourceSaver.save(atlas_textures[name], atlas_texture_path)
		if err != OK:
			print("AtlasTexture save error: %s" % error_string(err))
			return err
		# atlas_textures[name].take_over_path(atlas_texture_path)
	
	return OK

static func make_or_load_named_styleboxes(atlas_textures: Dictionary, spritesheet_data: Dictionary, source_file_folder: String) -> Dictionary:
	
	# Result
	var styleboxes: Dictionary = {}
	
	# Make atlas textures
	for slice in spritesheet_data.meta.slices:
		var name: String = slice.name
		if name.ends_with("-noimp"):
			continue
		if "center" not in slice.keys[0]:
			continue
		
		# Make or load StyleBox
		var stylebox_path: String = "%s/textures/%s_stylebox.tres" % [source_file_folder, name]
		var stylebox: StyleBoxTexture
		if FileAccess.file_exists(stylebox_path):
			stylebox = load(stylebox_path)
		else:
			stylebox = StyleBoxTexture.new()
			
		stylebox.texture = atlas_textures[name]
		stylebox.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		stylebox.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		
		stylebox.texture_margin_left = slice.keys[0].center.x
		stylebox.texture_margin_top = slice.keys[0].center.y
		stylebox.texture_margin_bottom = slice.keys[0].bounds.w - slice.keys[0].center.x - slice.keys[0].center.w
		stylebox.texture_margin_right = slice.keys[0].bounds.h - slice.keys[0].center.y - slice.keys[0].center.h
		
		styleboxes[name] = stylebox
		
	return styleboxes

static func save_named_styleboxes(styleboxes: Dictionary, source_file: String, source_file_folder: String) -> Error:
	
	# Save each entry as an atlas texture
	for name in styleboxes:
		var stylebox_path: String = "%s/textures/%s_stylebox.tres" % [source_file_folder, name]
		var err = ResourceSaver.save(styleboxes[name], stylebox_path)
		if err != OK:
			print("StyleBoxTexture save error: %s" % error_string(err))
			return err
		# styleboxes[name].take_over_path(stylebox_path)
	
	return OK
