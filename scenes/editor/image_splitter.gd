@tool
extends Node2D
class_name ImageSplitter

### Image Splitter for ColorID images used to define territories in strategy games

#@export_category("Inputs")
## Texture that is used to split all textures
@export var color_id_texture: Texture2D
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
@export_category("Clear")
## Run the script to split images
@export var clear_all: bool = false

func _clear_all() -> void:
	colors = []
	masks = []
	backgrounds = []
	mask_offsets = []
	crest_locations =[]
	for node in $Output.get_children():
		node.queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if split_images and is_instance_valid( color_id_texture ) and is_instance_valid( background_texture ):
			create_masks()
			crop_masks()
			print("images_split")
			split_images = false
			if create_nodes:
				_create_nodes()
				print("created_nodes")
		if clear_all:
			_clear_all()
			clear_all = false
		
func _create_nodes() -> void:
	var output: Node2D = $Output
	
	for i in colors.size():
		var color = colors[i]
		var mask = masks[i]
		var background = backgrounds[i]
		var mask_offset = mask_offsets[i]
		
		var color_node = Node2D.new() # Node parent per color
		color_node.name = "ColorID_" + str( i )
		output.add_child( color_node )
		color_node.owner = get_tree().edited_scene_root
		
		var mask_node = Sprite2D.new()
		mask_node.name = "Mask"
		color_node.add_child( mask_node )
		mask_node.owner = get_tree().edited_scene_root
		
		var bg_node = Sprite2D.new()
		bg_node.name = "BG"
		color_node.add_child( bg_node )
		bg_node.owner = get_tree().edited_scene_root
		
		mask_node.texture = mask.duplicate()
		bg_node.texture = background.duplicate()
		
		color_node.position = mask_offset
		

func get_id_by_color( color: Color ) -> int:
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

## Creates masks per color, size of the color_id texture 
func create_masks( ) -> void:
	
	masks = []
	colors = []
	mask_offsets = []
	
	# load the ColorID image
	var source = color_id_texture.get_image()
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

## Crops masks to white pixels + 1 radius
func crop_masks(  ) -> void:
	## TODO: 
	## Handle colored background image cropping
	## Adjustable radius
	## Multiple Layers? Someday amybe
	
	for id in colors.size(): # one loop per color
		var image = masks[id]
		var bg = backgrounds[id]

		var target_rect: Rect2 = Rect2() 
		var source_rect: Rect2i = Rect2i()
		
		var left: int = image.get_width()
		var top: int  = image.get_height()
		var right: int
		var bottom: int
		
		for x in range(image.get_width()):
			for y in range(image.get_height()):
				var color = image.get_pixel(x, y)
				if color.is_equal_approx(Color.WHITE):
					left = min( left, x )
					right = max( right, x )
					top = min( top, y )
					bottom = max( bottom, y )
					
		source_rect = Rect2i( left, top, right - left, bottom - top )
		target_rect = source_rect.grow( 1 )
		
		# I bet there's a way to do this simpler but this is what ChatGPT told me 
		
		# expand the rect by 1 pixel to all directions
		left = max(0, left - 1) # Clamp at 0
		top = max(0, top - 1) # Clamp at 0
		right = min(image.get_width() - 1, right + 1)
		bottom = min(image.get_height() - 1, bottom + 1)

		# limit the rect by the image extents
		target_rect.position.x = max(0, left)
		target_rect.position.y = max(0, top)
		target_rect.size.x = min(image.get_width() - 1, right)
		target_rect.size.y = min(image.get_height() - 1, bottom)
		
		# MASK
		var cropped = Image.create( target_rect.size.x, target_rect.size.y, false, Image.FORMAT_RGBA8 )
		cropped.blit_rect( image, target_rect, Vector2i(0,0) )
		masks[id] = cropped
		
		# BG
		var cropped_bg = Image.create( target_rect.size.x, target_rect.size.y, false, Image.FORMAT_RGBA8 )
		cropped_bg.blit_rect( backgrounds[id], target_rect, Vector2i(0,0) )
		backgrounds[id] = cropped_bg
		
		mask_offsets.append( target_rect.get_center() )



