@tool
class_name AsepriteSpriteFrameTools
extends RefCounted

static func make_atlas_textures(tex: Texture2D, spritesheet_data: Dictionary) -> Array[AtlasTexture]:
	
	# Make atlas textures
	var atlas_textures: Array[AtlasTexture] = []
	for key in spritesheet_data.frames:
		var atex = AtlasTexture.new()
		atex.atlas = tex
		atex.region.position.x = spritesheet_data.frames[key].frame.x
		atex.region.position.y = spritesheet_data.frames[key].frame.y
		atex.region.size.x = spritesheet_data.frames[key].frame.w
		atex.region.size.y = spritesheet_data.frames[key].frame.h
		atlas_textures.push_back(atex)
	
	return atlas_textures

static func add_animations_to_spriteframes(sprite_frames: SpriteFrames, spritesheet_data: Dictionary, atlas_textures: Array[AtlasTexture]):
	
	# Enumerate frames
	var frames = []
	for key in spritesheet_data.frames:
		frames.push_back(spritesheet_data.frames[key])

	# Add in animations
	for tag in spritesheet_data.meta.frameTags:
		var anim_name: String = tag.name
		if anim_name.ends_with("-noimp"):
			continue
		sprite_frames.add_animation(anim_name)
		
		# FPS is based on the first animation frame
		var ms_per_frame = float(frames[tag.from].duration)
		var fps = 1.0 / (ms_per_frame / 1000.0)
		sprite_frames.set_animation_speed(anim_name, roundf(fps))
		
		# Animation looping is based off "loop" or "cycle" hint
		sprite_frames.set_animation_loop(anim_name, anim_name.ends_with("loop") or anim_name.ends_with("cycle"))
		
		# Animation direction
		var frame_range = range(tag.from, tag.to+1) # forwards 
		if tag.direction == "reverse":
			frame_range = range(tag.to, tag.from-1, -1) # backwards 
		if tag.direction == "pingpong":
			frame_range = range(tag.from, tag.to) + range(tag.to, tag.from, -1) # ping-pong
		
		for i in frame_range:
			var frame_duration = frames[i].duration / ms_per_frame
			sprite_frames.add_frame(anim_name, atlas_textures[i], frame_duration)

	# Remove default animation if necessary
	var has_default = false
	for tag in spritesheet_data.meta.frameTags:
		if tag.name == "default":
			has_default = true
			break
	if !has_default:
		sprite_frames.remove_animation("default")
