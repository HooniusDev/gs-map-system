extends Node
class_name MapManager

### Used to relay stuff between "Main" and "Map"

@onready var map: Map = $Map as Map
## Territories Parent
@onready var territories: Node2D = $Map/Territories

## Returns Territory ID at position
func get_territory_id_by_position( position: Vector2i ) -> int:
	if map.bounds.has_point(position):
		var color = map.get_color( position )
		if color.a < 0.04:
			return -1
		for territory in $Map/Territories.get_children():
			if territory.is_color(color):
				return territory.id
	else:
		printerr("get_territory_from_position out of bounds ", position)
		return -1
	return -1
	
## Returns Territory 
func get_territory_by_id( id: int ) -> Territory:
	if id > territories.get_child_count():
		printerr( "Territory ID out of Bounds!" )
		return null
	return territories.get_child(id)


#func get_color_id( position: Vector2i ):
	#if map_bounds.has_point( position ):
		#return color_id.get_image().get_pixel( position.x, position.y )
	#else:
		#printerr("get_territory_from_position out of bounds ", position)
		#return null



		

