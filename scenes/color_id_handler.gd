extends TextureRect

## TODO: implement this really
signal texture_changed

### This node needs to update info about color_id image
## colors_count
## images for the territories
## special pixels on those color regions
## etc

## Map can then fetch that info and use it for creating nodes

## Should this be made into ColorID Resource
@export var file_name: StringName = ""
@export var file_path: StringName = ""
@export var colors: Array[Color] = []
@export var masks: Array[Image] = []
@export var mask_offsets: Array[Vector2i] = []

@export var crest_locations: Array[Vector2i] = []

func _ready() -> void:
	if texture:
		load_sprite()

func load_sprite() -> void:
	create_masks()
	crop_masks()
	
func get_id_by_color( color: Color ) -> int:
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

func get_id_by_position( position: Vector2i ) -> int:
	if not get_rect().has_point(position):
		return -1
	var color = texture.get_image().get_pixelv( position )
	return get_id_by_color( color )

func set_sprite_to_territory( index: int, sprite: Sprite2D ) -> void:
	if index >= colors.size():
		print("Set Sprite failed due to oveflow ", index)
		return
	sprite.position = mask_offsets[index]
	sprite.texture = ImageTexture.create_from_image( masks[index] )

func create_masks( ) -> void:
	
	 # load the ColorID image
	var source = texture.get_image()
	
	for y in source.get_height():
		for x in source.get_width():
			var color = source.get_pixel( x, y )
			# transparent -> discard pixel
			if color.a < 0.01:
				continue
			# red -> crest location
			if color.is_equal_approx( "ff0000" ):
				# get pixel right to this
				color = source.get_pixel( x+1, y )
				crest_locations.append( Vector2i(x,y) )
			var id = get_id_by_color( color )
			# this is already in colors
			if id > -1:
				masks[id].set_pixel(x,y, Color.WHITE)
			# new color so create new entry to colors
			else:
				var image = Image.create( source.get_size().x, source.get_size().y, false, Image.FORMAT_RGBA8 )
				masks.append( image )
				image.set_pixel(x,y, Color.WHITE)
				colors.append(color)


func crop_masks(  ) -> void:
	for id in colors.size():
		var image = masks[id]
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
		
		mask_offsets.append( Vector2i(left, top) )

		masks[id] = cropped
		#cropped_array.append(texture)
