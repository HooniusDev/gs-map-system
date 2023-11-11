extends Node
class_name MapEditor

### Used for Tiny64 Map loading
# Could be extended to dynamically load territories from image and 
# adding random names. 
# Map.gd is almost the same but not :P

## Holds the TerritoryData. Same data is accessible from Territories Node
@export var map_data: MapData

## Graphics of the map
@export var visual: Texture2D
## Features "layer", not used yet
@export var features: Texture2D
## Color ID map of territories
@export var color_id: Texture2D
## Borders image
@export var borders: Texture2D

var map_bounds: Rect2i

func _ready() -> void:
	_create_masks()
	map_bounds = Rect2i( 0,0,color_id.get_width() , color_id.get_height())

func get_color_id( position: Vector2i ):
	if map_bounds.has_point( position ):
		return color_id.get_image().get_pixel( position.x, position.y )
	else:
		printerr("get_territory_from_position out of bounds ", position)
		return null


func get_territory_id( position: Vector2i ) -> int:
	if map_bounds.has_point( position ):
		var color = color_id.get_image().get_pixel( position.x, position.y )
		return map_data.get_territory_id_by_color( color )
	else:
		printerr("get_territory_from_position out of bounds ", position)
		return -1
		
## Loads colors from image and assigns them to territories mask images
func _create_masks():
	# for each territory, create white mask texture based on territory color
	var image: Image = color_id.get_image()
	
	for territory in map_data.territories:
		territory._mask = Image.create( color_id.get_size().x, color_id.get_size().y, false, Image.FORMAT_RGBA8 )
		#print("Creating mask for: ", territory._name)
		for y in color_id.get_height():
			 for x in color_id.get_width():
				var color = image.get_pixel( x, y )
				#print( "Color: ", color, "Territory: ", territory._color )
				if color.is_equal_approx(territory._color):
					territory._mask.set_pixel(x,y, Color.WHITE)
				else:
					territory._mask.set_pixel(x,y, Color.TRANSPARENT)

## Spawns Territory Nodes                
func aspawn_territories():
	for territory_data in map_data.territories:
		var territory: Territory = preload("res://scenes/territory.tscn").instantiate() as Territory
		territory.data = territory_data
		territory.data.territory_id = %Territories.get_child_count()
		%Territories.add_child( territory )
		territory.name = territory_data._name
		var texture = ImageTexture.create_from_image( territory_data._mask )
		var sprite: Sprite2D = territory.get_node("Mask")
		sprite.texture = texture
		sprite.visible = false
