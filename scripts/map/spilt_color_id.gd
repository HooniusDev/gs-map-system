@tool
extends Node
class_name SplitColorID

@onready var color_id: Sprite2D = $ColorID
@onready var territories: Node2D = $Map/Territories

var color_id_image: Image

var colors_array: Array[Color]
var cropped_array: Array[ImageTexture]
var positions_array: Array[Vector2i]

var masks_array: Array[Image]
@export var clear_territories: bool = false

func _ready() -> void:
	#property_list_changed.connect(create_masks)
	color_id.texture_changed.connect(on_color_id_changed)   #.changed.connect(create_masks)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if clear_territories == true:
			print("WADAD")
			for node in territories.get_children():
				node.queue_free()
			clear_territories = false
	
func on_color_id_changed():
# Clear old Territories ( Update data? )
	if !color_id.texture:
		for node in territories.get_children():
			node.queue_free()
		return
		
# Create masks
	print("create_masks")
	create_masks()
# Crop masks
	print("crop_masks")
	crop_masks()
# Spawn Territory
	print("spawn_territories")
	spawn_territories()
# Set Territory Data
	call_deferred( "setup_territories" )
	# colorID
	# ID
	# Mask textures

func spawn_territories():
	for i in colors_array.size():
		var territory = preload("res://scenes/territory.tscn").instantiate()
		territories.add_child( territory )
		territory.owner = get_tree().edited_scene_root


	
func setup_territories():
	for i in territories.get_child_count():
		var territory = territories.get_children()[i]
		territory.setup(cropped_array[i], colors_array[i], $Crest.texture)
		territory.id = i
		territory.position = positions_array[i]
		territory.name = "territory_" + str(i)



func create_masks(  ) -> void:
	
	 # load the ColorID image
	var source = color_id.texture.get_image()
	
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			if color.a < 0.01:
				continue
			# If it is territory color set it to White, else Transparent
			if colors_array.has(color):
				var index = colors_array.find( color )
				masks_array[index].set_pixel(x,y, Color.WHITE)
			else:
				colors_array.append(color)
				masks_array.append( Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 ) )
				var index = colors_array.find( color )
				masks_array[index].set_pixel(x,y, Color.WHITE)


func crop_masks( ) -> void:
	for i in masks_array.size():
		var image = masks_array[i]
		# based on image white pixels crop
		var rect: Rect2i = Rect2i()
		
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
					
		rect = Rect2i( left, top, right - left + 1, bottom - top + 1 )
		var cropped = Image.create( rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8 )
		
		cropped.blit_rect( image, rect, Vector2i(0,0) )
		
		positions_array.append( Vector2i(left, top) )
		
		var texture = ImageTexture.create_from_image( cropped )
		cropped_array.append(texture)
		

		
		#var t = Node2D.new()
		#t.set_script( preload("res://scripts/map/territory.gd") )
		#territories.add_child( t )
		#t.owner = get_tree().edited_scene_root
		#t.id = i
		#t.position = Vector2i( left, top )
		#t.name = "territory_" + str(i)
		#territory
	

	
#func _spawn_territory(position: Vector2i, texture: ImageTexture):
	#var territory = preload("res://scenes/territory.tscn").instantiate()
	#
	##territory.highlight_overlay.texture = texture
	##territory.highlight_overlay.centered = false
	##territory.highlight_overlay.self_modulate = "ffffff68"
	##var sprite = Sprite2D.new()
	##sprite.texture = texture
	##sprite.centered = false
	###sprite.region_enabled = true
	###sprite.region_rect = rect
	##sprite.position = position
	##sprite.self_modulate = "ffffff68"
	#
	#territories.add_child( territory )
	#territory.owner = get_tree().edited_scene_root
	#territory.set_textures(texture)
	#territory.position = position
	#set_editable_instance(territory, true)
	
	

func has_color( color: Color, color_array: Array[Color] ) -> bool:
	# Do we need "color.is_equal_approx(color2)"
	if color_array.has( color ):
		return true
	else:
		return false


func _on_crest_changed() -> void:
	print("Crest update")
	for territory in territories.get_children():
		print("region rect")
		territory.crest.region_enabled = true
		territory.crest.region_rect = $Crest.region_rect
	pass # Replace with function body.
