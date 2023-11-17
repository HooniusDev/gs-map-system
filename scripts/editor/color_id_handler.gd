extends Sprite2D
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
@export var mask_offsets: Array[Vector2] = []

@export var crest_locations: Array[Vector2] = []

func _ready() -> void:
	if texture:
		_handle_sprite()
		_on_color_id_loaded()
	pass

func load_texture( path: String ) -> bool:
	if file_path != path:
		### Load was much easier than i thought ###
		texture = load(path)
		_handle_sprite()
		_on_color_id_loaded()
		return true
	else:
		print("loading same image again")
		return false

func _on_color_id_loaded():
	MapEditorEvents.color_id_texture_changed.emit()
	#print( "size: " , size , " to:" , texture.get_size() )
	#size = texture.get_size()
	#get_parent().size = texture.get_size()

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

func get_id_by_position( pos: Vector2 ) -> int:
	var local: = pos + texture.get_size() / 2.0
	print("local: ", local)
	var rect = Rect2i( Vector2i(0,0), texture.get_size() )
	if not rect.has_point(local):
		printerr(" out ! ", local)
		return -1
	var color = texture.get_image().get_pixelv( local )
	return get_id_by_color( color )

func set_sprite_to_territory( index: int, sprite: Sprite2D ) -> void:
	if index >= colors.size():
		print("Set Sprite failed due to oveflow ", index)
		return
	sprite.texture = ImageTexture.create_from_image( masks[index] )
	sprite.position = mask_offsets[index] - texture.get_size() * .5

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
				crest_locations.append( Vector2(x,y) )
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
		var target_rect: Rect2 = Rect2i()
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
		mask_offsets.append( target_rect.get_center() )

		masks[id] = cropped
