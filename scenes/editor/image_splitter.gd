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
		update_configuration_warnings()
		
## The artsy image of the map
@export var background_texture: Texture2D:
	set ( texture ):
		background_texture = texture
		update_configuration_warnings()

@export_category("Outputs")
## Colors in order that they are discovered from color_id image
@export var colors: Array[Color] = []
## B/W images of territories
@export var masks: Array[Image] = []
## Graphics of territory cropped by mask
@export var backgrounds: Array[Image] = []
## Offsets of cropped images to match original background
@export var mask_offsets: Array[Vector2] = []

var color_id_no_crests: Image

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
	output.queue_free()
		
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

## TODO: 

## Re create Inputs and Outputs nodes so if they are saved they dont reference the saved ones

## Duplicate color_id so crest locations stay on the Input texture
## Add output versions of ColorID and Background
## Output colors array


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if split_images and is_instance_valid( color_id_texture ) and is_instance_valid( background_texture ):
			
			var image = color_id_texture.get_image()
			color_id_no_crests = image.duplicate()
			color_id_no_crests.resource_local_to_scene = true
			
			process_colors()
			read_crest_locations()
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
	
	var inputs: Node2D = $Inputs
	
	var output: Node2D = Node2D.new()
	output.name = "Output"
	output.texture = background_texture
	add_child( output )
	output.owner = get_tree().edited_scene_root



	var bg = Sprite2D.new()
	bg.name = "Background"
	bg.texture = background_texture
	output.add_child( bg )
	bg.owner = get_tree().edited_scene_root
	
	var color_id_output = Sprite2D.new()
	color_id_output.name = "ColorID_Texture"
	color_id_output.texture = ImageTexture.create_from_image( color_id_no_crests )
	output.add_child( color_id_output )
	color_id_output.owner = get_tree().edited_scene_root
	

	for i in colors.size():
		
		var color = colors[i]
		var mask = masks[i]
		var background = backgrounds[i]
		var mask_offset = mask_offsets[i]
		
		var color_node = Node2D.new() # Node parent per color
		color_node.name = "Id_" + str( i )
		color_id_output.add_child( color_node )
		color_node.owner = get_tree().edited_scene_root
		color_node.position = mask_offset
		color_node.self_modulate = color
		
		var mask_node = Sprite2D.new()
		mask_node.name = "Mask"
		mask_node.texture = ImageTexture.create_from_image( mask )
		color_node.add_child( mask_node )
		mask_node.owner = get_tree().edited_scene_root
		
		var bg_node = Sprite2D.new()
		bg_node.name = "BG"
		bg_node.texture = ImageTexture.create_from_image( background )
		color_node.add_child( bg_node )
		bg_node.owner = get_tree().edited_scene_root
		
		var crest_marker = Marker2D.new() # Node parent per color
		crest_marker.name = "Crest"
		color_node.add_child( crest_marker )
		crest_marker.owner = get_tree().edited_scene_root
		crest_marker.global_position = crest_locations[i] - Vector2(color_id_texture.get_width() * .5, color_id_texture.get_height() * .5 )
		
	
	inputs.visible = false
	
	var color_id = Sprite2D.new()
	color_id.name = "ColorID"
	color_id.texture = color_id_texture
	inputs.add_child( color_id )
	color_id.owner = get_tree().edited_scene_root
	
	var bg_input = Sprite2D.new()
	bg_input.name = "Background"
	bg_input.texture = background_texture
	inputs.add_child( bg_input )
	bg_input.owner = get_tree().edited_scene_root
		
func get_id_by_color( color: Color ) -> int:
	if color.a < 0.01:
		return -1
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

func process_colors() -> void:
	
	var source = color_id_texture.get_image()
	
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			if color.a < 0.01:
				continue
			if color.is_equal_approx( "ff0000" ):
				continue
			var id = get_id_by_color( color )
			if id < 0:
				colors.append(color)
				
	for i in colors.size():
		masks.append( Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 ) )
		backgrounds.append( Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 ) )
		crest_locations.append(Vector2.ZERO)

## Creates masks per color, size of the color_id texture 
func create_masks( ) -> void:
	
	mask_offsets = []
	
	# load the ColorID image
	var source = color_id_texture.get_image()
	var bg_image = background_texture.get_image()
	
	if not is_instance_valid(source):
		printerr("Texture is shit!")
		
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			var id = get_id_by_color( color )
			
			if color.a < 0.01: # transparent -> discard pixel
				continue
			if color.is_equal_approx( "ff0000" ):
				print("crest color: ", Vector2(x,y))
				var color_id = source.get_pixel( x + 1, y )
				id = get_id_by_color( color_id )
				masks[id].set_pixel(x,y, Color.WHITE)
				var pixel = bg_image.get_pixel( x, y )
				backgrounds[id].set_pixel(x,y, pixel)
				color_id_no_crests.set_pixel( x, y, color_id )
				continue
				
			# This is familiar color so add it to masks array
			if id > -1:
				masks[id].set_pixel(x,y, Color.WHITE)
				var bg_pixel = background_texture.get_image().get_pixel( x, y )
				backgrounds[id].set_pixel(x,y, bg_pixel)
			# Color is a new one
			else:
				masks[id].set_pixel(x,y, Color.WHITE)
				var bg_pixel = background_texture.get_image().get_pixel( x, y )
				backgrounds[id].set_pixel(x,y, bg_pixel)
				colors.append(color)
	
	# Do a second pass to add transparent pixels border pixels to bg's
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			if color.a > 0.1:
				continue
			if x > 0: # left
				var id = get_id_by_color( source.get_pixel( x - 1, y ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x, y))
					#backgrounds[id].set_pixel(x - 1,y, Color.BLUE_VIOLET)
			if x < source.get_width() - 1: #right
				var id = get_id_by_color( source.get_pixel( x + 1, y ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x, y))
			if y > 0: # up
				var id = get_id_by_color( source.get_pixel( x, y - 1 ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x, y))
			if y < source.get_height() - 1: # down
				var id = get_id_by_color( source.get_pixel( x, y + 1 ) )
				if id != -1: # There is a color
					backgrounds[id].set_pixel(x,y, bg_image.get_pixel( x, y))
				

## Crops masks to white pixels + 1 radius
func crop_masks(  ) -> void:
	## TODO: 
	## Handle colored background image cropping
	## Adjustable radius
	## Multiple Layers? Someday amybe
	
	for id in colors.size(): # one loop per color
		
		var image = masks[id]
		
		var left: float = image.get_width()
		var top: float  = image.get_height()
		var right: float = 0
		var bottom: float = 0
		
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
		right = min(image.get_width() - 1, right + 2)
		bottom = min(image.get_height() - 1, bottom + 2)

		var width: float = right - left
		var height: float = bottom - top
		
		var target_rect = Rect2( left, top, width, height )
		
		# MASK
		var cropped = Image.create( width, height, false, Image.FORMAT_RGBA8 )
		cropped.blit_rect( image, target_rect, Vector2i(0,0) )
		masks[id] = cropped
		
		# BG
		var cropped_bg = Image.create( width, height, false, Image.FORMAT_RGBA8 )
		cropped_bg.blit_rect( backgrounds[id], target_rect, Vector2i(0,0) )
		backgrounds[id] = cropped_bg
		
		var center = target_rect.get_center() - Vector2(image.get_width() * .5, image.get_height() * .5 )
		
		mask_offsets.append( center )
		

func read_crest_locations() -> void:
	
	var source = color_id_texture.get_image()

	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel(x,y)
			if color.is_equal_approx( "ff0000" ): # red -> crest location
				# pixel on right determines which color this crest belongs
				print( "read_crest_locations " , Vector2(x,y) )
				color = source.get_pixel( x + 1, y )
				var id = get_id_by_color( color )
				crest_locations[id] = Vector2(x,y)
				masks[id].set_pixel(x,y, Color.WHITE)
				#color_id_no_crests.set_pixel( x, y, Color.YELLOW )

func _get_configuration_warnings():
	var warnings = []

	if !color_id_texture:
		warnings.append("Color ID Texture is Required")
	
	if !background_texture:
		warnings.append("Background Texture is Required")

	# Returning an empty array means "no warning".
	return warnings

