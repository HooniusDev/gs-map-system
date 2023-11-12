extends Node2D
class_name PixelMap

## TODO:
## Make separate Editor Map and Game Map objects 

## Graphics of the map
#@onready var map_sprite: Sprite2D = $Images/Map
@onready var color_id: TextureRect = %ColorID

## Color ID image for easier color picking
@onready var color_id_image: Image 

## Bounds of the Map
var bounds: Rect2i

@export var hover_territory_id: int = -1
@export var focus_territory_id: int = -1

signal focus_territory_changed
signal hover_territory_changed

func _ready() -> void:
	#bounds = Rect2i( 0,0, color_id_image.get_size().x, color_id_image.get_size().y )
	pass

## Gets color at position
func get_color( pos: Vector2i ) -> Color:
	var _color = color_id_image.get_pixelv( pos )
	return _color
	
func _unhandled_input(event: InputEvent) -> void: #input(viewport: Node, event: InputEvent, shape_idx: int):
	print("mouuuuusse")
	## Update Mouse Position
	var mouse_pos: Vector2i = get_local_mouse_position().round()
	
	## If Left Clicked and Mouse Hovering over a Territory
	if event is InputEventMouseButton and event.is_released() and hover_territory_id != -1:
		
		## Set territory as selected
		focus_territory_id = hover_territory_id
		
		## Get the selected territory node
		
		#var territory = map_manager.get_territory_by_id(selected_territory_id)
		
		# TODO emit this for Global editor state to emit lost_focus on old one
		focus_territory_changed.emit(focus_territory_id) #
		
		## Faction 0 gets to conquer the territory for now
		#$Factions.accuire_territory( 0, territory )
	
		
	if event is InputEventMouseMotion:
		
		var territory_id = %ColorID.get_id_by_position( mouse_pos )

		## Mouse is not over a Territory
		if territory_id == -1:
			return
		#print("Mouse over map")
		## Mouse has just moved over a different Territory
		if territory_id != hover_territory_id:
			
			hover_territory_id = territory_id
			hover_territory_changed.emit(hover_territory_id)
			#color_id.set_sprite_to_territory( hover_territory_id, $"../CanvasLayer/Sprites/HoverVisualizer" )

		


#func _on_map_gui_input(event: InputEvent) -> void:
	#pass # Replace with function body.


