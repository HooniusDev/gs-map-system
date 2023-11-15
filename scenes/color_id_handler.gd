extends TextureRect
class_name ColorID

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
		_handle_sprite()
		_on_color_id_loaded()
	pass

func load_texture( path: String ) -> void:
	if file_path != path:
		### Load was much easier than i thought ###
		texture = load(path)
		_handle_sprite()
		_on_color_id_loaded()
	else:
		print("loading same image again")

func _on_color_id_loaded():
	MapEditor.color_id_changed.emit()
	print( "size: " , size , " to:" , texture.get_size() )
	size = texture.get_size()
	get_parent().size = texture.get_size()


func _handle_sprite( ) -> void:
	## all kinds of check here!
	### Should we create all new or just update data ###
	create_masks()
	crop_masks()
	
func get_id_by_color( color: Color ) -> int:
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

func get_id_by_position( pos: Vector2i ) -> int:
	if pos.x >= texture.get_width() or pos.y >= texture.get_height():
		return -1
	if pos.x < 0 or pos.y < 0:
		return -1
	var color = texture.get_image().get_pixelv( pos )
	return get_id_by_color( color )

func set_sprite_to_territory( index: int, sprite: Sprite2D ) -> void:
	if index >= colors.size():
		print("Set Sprite failed due to oveflow ", index)
		return
	sprite.texture = ImageTexture.create_from_image( masks[index] )
	sprite.position = mask_offsets[index] + Vector2i( position )

### BUG 
### On DotC map masks are a bit off
func create_masks( ) -> void:
	
	masks = []
	colors = []
	mask_offsets = []
	
	# load the ColorID image
	var source = texture.get_image()
	if not is_instance_valid(source):
		printerr("Texture is shit!")
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

### TODO:

func crop_masks(  ) -> void:
	for id in colors.size():
		
		var image = masks[id]
		# based on image white pixels crop
		var target_rect: Rect2i = Rect2i()
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
		
		# expand the rect by 1 pixel to all directions
		left = max(0, left - 1)
		top = max(0, top - 1)
		right = min(image.get_width() - 1, right + 1)
		bottom = min(image.get_height() - 1, bottom + 1)

		# limit the rect by the image extents
		target_rect.position.x = max(0, left)
		target_rect.position.y = max(0, top)
		target_rect.size.x = min(image.get_width() - 1, right)
		target_rect.size.y = min(image.get_height() - 1, bottom)
		
		#rect = Rect2i( left, top, right - left, bottom - top )
		
		var cropped = Image.create( target_rect.size.x, target_rect.size.y, false, Image.FORMAT_RGBA8 )
		
		cropped.blit_rect( image, target_rect, Vector2i(0,0) )
		
		### BUG: these get missed by a pixel?
		mask_offsets.append( Vector2i(target_rect.position.x, target_rect.position.y) )

		masks[id] = cropped
