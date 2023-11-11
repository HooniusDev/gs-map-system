@tool
extends Node
class_name  SplitColorID

@onready var color_id: Sprite2D = $ColorID
@onready var territories: Node2D = $Map/Territories

var color_id_image: Image

var color_count: int
 
var output_textures: Array[Texture]

func _ready() -> void:
	#property_list_changed.connect(create_masks)
	color_id.texture_changed.connect(create_masks)   #.changed.connect(create_masks)
	
func create_masks(  ) -> void:
	
	if !color_id.texture:
		for node in territories.get_children():
			node.queue_free()
		return
	
	print("create masks")
	 # load the ColorID image
	var source = color_id.texture.get_image()
	
	var colors_array: Array[Color]
	var images_array: Array[Image]
	
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			if color.a < 0.01:
				continue
			# If it is territory color set it to White, else Transparent
			if colors_array.has(color):
				var index = colors_array.find( color )
				images_array[index].set_pixel(x,y, Color.WHITE)
			else:
				colors_array.append(color)
				images_array.append( Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 ) )
				var index = colors_array.find( color )
				images_array[index].set_pixel(x,y, Color.WHITE)
				
	for node in territories.get_children():
		node.queue_free()
				
	
	for image in images_array:
		crop_mask(image)
		

func crop_mask( image: Image ) -> void:
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
	print(rect)
	
	cropped.blit_rect( image, rect, Vector2i(0,0) )
	
	var texture = ImageTexture.create_from_image( cropped )
	
	_spawn_territory(Vector2i( left, top ), texture)
	
	#var sprite = Sprite2D.new()
	#sprite.texture = texture
	#sprite.centered = false
	##sprite.region_enabled = true
	##sprite.region_rect = rect
	#sprite.position = Vector2i( left, top )
	#sprite.self_modulate = "ffffff68"
	#
	#$Masks.add_child( sprite )
	#sprite.owner = get_tree().edited_scene_root
	print("Sopwn")
	
func _spawn_territory(position: Vector2i, texture: ImageTexture):
	var territory = preload("res://scenes/territory.tscn").instantiate()
	
	#territory.highlight_overlay.texture = texture
	#territory.highlight_overlay.centered = false
	#territory.highlight_overlay.self_modulate = "ffffff68"
	#var sprite = Sprite2D.new()
	#sprite.texture = texture
	#sprite.centered = false
	##sprite.region_enabled = true
	##sprite.region_rect = rect
	#sprite.position = position
	#sprite.self_modulate = "ffffff68"
	
	territories.add_child( territory )
	territory.owner = get_tree().edited_scene_root
	territory.texture = texture
	territory.position = position
	
	
	

func has_color( color: Color, color_array: Array[Color] ) -> bool:
	# Do we need "color.is_equal_approx(color2)"
	if color_array.has( color ):
		return true
	else:
		return false
