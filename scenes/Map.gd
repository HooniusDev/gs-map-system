extends Node2D
class_name Map

## Holds the TerritoryData. Same data is accessible from Territories Node
## TODO:
## Make separate Editor Map and Game Map objects 

## Im avoiding to use this. For Editor use only
@export var map_data: MapData

## Graphics of the map
@onready var map: Sprite2D = $Images/Map

## Features "layer" Castles and Forest are in this Sprite
@onready var features: Sprite2D = $Images/Features

## Color ID map of territories
@onready var color_ids: Sprite2D = $Images/ColorIds

## Color ID image for easier color picking
@onready var color_id_image: Image 

## Borders image
@onready var borders: Sprite2D = $Images/Borders

## Territories parent
@onready var territories: Node2D = $Territories

## Bounds of the Map
var bounds: Rect2i

func _ready() -> void:
	_create_masks()
	_spawn_territories()
	bounds = Rect2i( 0,0, color_id_image.get_size().x, color_id_image.get_size().y )

## Gets color at position
func get_color( pos: Vector2i ) -> Color:
	var _color = color_id_image.get_pixelv( pos )
	return _color
	
	
## Loads colors from image and assigns them to territories mask images
func _create_masks():
	# load the ColorID image
	color_id_image = color_ids.texture.get_image()
	
	# for each territory, create white mask texture based on territory color
	for territory in map_data.territories:
		# Create new image
		territory._mask = Image.create( color_id_image.get_size().x, color_id_image.get_size().y, false, Image.FORMAT_RGBA8 )
		
		# Go through every pixel
		for y in color_id_image.get_height():
			for x in color_id_image.get_width():
				var color = color_id_image.get_pixel( x, y )
				# If it is territory color set it to White, else Transparent
				if color.is_equal_approx(territory._color):
					territory._mask.set_pixel(x,y, Color.WHITE)
				else:
					territory._mask.set_pixel(x,y, Color.TRANSPARENT)
	print("Masks created")

## Spawns Territory Nodes                
func _spawn_territories():
	for territory_data in map_data.territories:
		var territory: Territory = preload("res://scenes/territory.tscn").instantiate() as Territory
		territory.id = territories.get_child_count(-1)
		territories.add_child( territory )
		territory.name = territory_data.name
		territory.data = territory_data
		territory.data.owner_id = -1
		# Copy Mask image to Overlays
		territory.highlight_overlay.texture = ImageTexture.create_from_image( territory_data._mask )
		territory.faction_overlay.texture = ImageTexture.create_from_image( territory_data._mask )

	print("Territories Spawned")


