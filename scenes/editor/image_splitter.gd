@tool
extends Node2D
class_name ImageSplitter

### Image Splitter for ColorID images used to define territories in strategy games

#@export_category("Inputs")
## Texture that is used to split all textures
@export var color_id_texture: Texture2D:
	set ( texture ):
		color_id_texture = texture
		if color_id_texture:
			save_folder = color_id_texture.resource_path.get_base_dir() + "/split/"
		
## The artsy image of the map
@export var background_texture: Texture2D

@export_category("Outputs")
## Colors in order that they are discovered from color_id image
@export var colors: Array[Color] = []
## B/W images of territories
@export var masks: Array[Image] = []
## Graphics of territory cropped by mask
@export var backgrounds: Array[Image] = []
## Offsets of cropped images to match original background
@export var mask_offsets: Array[Vector2] = []

## Experimental marking of locations
@export var crest_locations: Array[Vector2] = []


@export_category("Run Tool")
## Run the script to split images
@export var split_images: bool = false
## Builds nodes from the output
@export var create_nodes: bool = true
## Save folder for PNG's
@export var save_folder: String = ""
## Save PNG's
@export var save_png: bool = false
@export_category("Clear")
## Clear Nodes from Output and Empty Arrays
@export var clear_all: bool = false


func _clear_all() -> void:
	var output = $Output
	var inputs = $Inputs
	colors = []
	masks = []
	backgrounds = []
	mask_offsets = []
	crest_locations =[]
	for node in output.get_children():
		node.queue_free()
	for node in inputs.get_children():
		node.queue_free()
		
func _save_pngs() -> void:
	
	## TODO:
	## Fetch names from Output Nodes
	
	print("_save_pngs")
	
	var output = $Output
	
	if output.get_child_count() == 0:
		printerr("Create and Name Your Nodes First")
		return
		
	if output.get_child(0).name == "ColorID_0":
		print("You should name the Nodes before saving")
	
	if not DirAccess.dir_exists_absolute(save_folder):
		DirAccess.make_dir_absolute(save_folder)
	
	for i in output.get_child_count():
		
		var node = output.get_child(i)
		
		var save_path = save_folder + node.name + "/"
		
		if not DirAccess.dir_exists_absolute(save_path):
			DirAccess.make_dir_absolute(save_path)
		
		print( "Saving png: " + node.name )
		
		if backgrounds.size() >= i:
			var png: Image = backgrounds[i]
			png.save_png( save_path + "bg_" + node.name + ".png" )
		if masks.size() >= i:
			var png: Image = masks[i]
			png.save_png( save_path + "mask_" + node.name + ".png" )


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if split_images and is_instance_valid( color_id_texture ) and is_instance_valid( background_texture ):
			create_masks()
			crop_masks()
			split_images = false
			if create_nodes:
				_create_nodes()
		if clear_all:
			_clear_all()
			clear_all = false
		if save_png:
			_save_pngs()
			save_png = false
		
func _create_nodes() -> void:
	
	var output: Node2D = $Output
	var inputs: Node2D = $Inputs

	for i in colors.size():
		var color = colors[i]
		var mask = masks[i]
		var background = backgrounds[i]
		var mask_offset = mask_offsets[i]
		
		var color_node = Node2D.new() # Node parent per color
		color_node.name = "ColorID_" + str( i )
		output.add_child( color_node )
		color_node.owner = get_tree().edited_scene_root
		color_node.set_meta("_edit_group_" + str(i), true)
		
		var mask_node = Sprite2D.new()
		mask_node.name = "Mask"
		mask_node.texture = ImageTexture.create_from_image( mask )
		color_node.add_child( mask_node )
		mask_node.owner = get_tree().edited_scene_root
		mask_node.set_meta("_edit_group_" + str(i), true)
		
		var bg_node = Sprite2D.new()
		bg_node.name = "BG"
		bg_node.texture = ImageTexture.create_from_image( background )
		color_node.add_child( bg_node )
		bg_node.owner = get_tree().edited_scene_root
		mask_node.set_meta("_edit_group_" + str(i), true)
		
		color_node.position = mask_offset
	
	inputs.visible = false
	
	var color_id = Sprite2D.new()
	color_id.name = "ColorID"
	color_id.texture = color_id_texture
	inputs.add_child( color_id )
	color_id.owner = get_tree().edited_scene_root
	
	var bg = Sprite2D.new()
	bg.name = "Background"
	bg.texture = background_texture
	inputs.add_child( bg )
	bg.owner = get_tree().edited_scene_root
		


func get_id_by_color( color: Color ) -> int:
	if color.is_equal_approx(Color.TRANSPARENT):
		return -1
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

### TODO:
### Extend background image by one pixel

## Creates masks per color, size of the color_id texture 
func create_masks( ) -> void:
	
	masks = []
	colors = []
	mask_offsets = []
	
	# load the ColorID image
	var source = color_id_texture.get_image()
	var bg_image = background_texture.get_image()
	
	if not is_instance_valid(source):
		printerr("Texture is shit!")
		
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			if color.a < 0.01: # transparent -> discard pixel
				continue
			if color.is_equal_approx( "ff0000" ): # red -> crest location
				# pixel on right determines which color this crest belongs
				color = source.get_pixel( x+1, y )
				crest_locations.append( Vector2(x,y) )
			var id = get_id_by_color( color )
			# This is familiar color so add it to masks array
			if id > -1:
				masks[id].set_pixel(x,y, Color.WHITE)
				var bg_pixel = background_texture.get_image().get_pixel( x, y )
				backgrounds[id].set_pixel(x,y, bg_pixel)
			# Color is a new one
			else:
				var mask = Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 )
				var bg = Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 )
				masks.append( mask )
				backgrounds.append( bg )
				mask.set_pixel(x,y, Color.WHITE)
				var bg_pixel = background_texture.get_image().get_pixel( x, y )
				backgrounds[id].set_pixel(x,y, bg_pixel)
				colors.append(color)
	
	# Do a second pass to add transparent pixels border pixels to bg's
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			if color.is_equal_approx(Color.TRANSPARENT):
				return
			if x > 0: # left
				var id = get_id_by_color( source.get_pixel( x - 1, y ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x - 1, y))
			if x < source.get_width() - 1: #right
				var id = get_id_by_color( source.get_pixel( x + 1, y ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x + 1, y))
			if y > 0: # up
				var id = get_id_by_color( source.get_pixel( x, y - 1 ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x, y - 1))
			if y < source.get_height() - 1: # down
				var id = get_id_by_color( source.get_pixel( x, y + 1 ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x, y + 1))

				
## Crops masks to white pixels + 1 radius
func crop_masks(  ) -> void:
	## TODO: 
	## Handle colored background image cropping
	## Adjustable radius
	## Multiple Layers? Someday amybe
	
	for id in colors.size(): # one loop per color
		var image = masks[id]
		var bg = backgrounds[id]
		
		var left: int = image.get_width()
		var top: int  = image.get_height()
		var right: int = 0
		var bottom: int = 0
		
		for x in range(image.get_width()):
			for y in range(image.get_height()):
				var color = image.get_pixel(x, y)
				if color.is_equal_approx(Color.WHITE):
					left = min( left, x )
					right = max( right, x )
					top = min( top, y )
					bottom = max( bottom, y )
		
		# expand the rect by 1 pixel to all directions
		left = max(0, left - 1) # Clamp at 0
		top = max(0, top - 1) # Clamp at 0
		right = min(image.get_width() - 1, right + 1)
		bottom = min(image.get_height() - 1, bottom + 1)

		var width = right - left
		var height = bottom - top
		
		var target_rect = Rect2( left, top, width, height )
		
		# MASK
		var cropped = Image.create( width, height, false, Image.FORMAT_RGBA8 )
		cropped.blit_rect( image, target_rect, Vector2i(0,0) )
		masks[id] = cropped
		
		# TODO: Need include mask +1 pixels
		# BG
		var cropped_bg = Image.create( width, height, false, Image.FORMAT_RGBA8 )
		cropped_bg.blit_rect( backgrounds[id], target_rect, Vector2i(0,0) )
		backgrounds[id] = cropped_bg
		
		mask_offsets.append( target_rect.get_center() - Vector2(image.get_width() * .5, image.get_height() * .5 ) )



