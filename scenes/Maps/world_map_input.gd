extends StaticBody2D
class_name WorldMapInput

var world_map: WorldMap

var hover_territory_id: int = -1

func setup_input( map: WorldMap, sprite: Sprite2D ) -> void:
	world_map = map
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2i( sprite.get_rect().size.x, sprite.get_rect().size.y )
	$CollisionShape2D.shape = shape

func _ready() -> void:
	pass

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	var new_hover_id = world_map.get_id_by_position( get_local_mouse_position() )
	if (new_hover_id == -1):
		return
	
	if event is InputEventMouseMotion:
		if new_hover_id != hover_territory_id:
			GameEvents.hover_territory_changed.emit( hover_territory_id, new_hover_id )
			hover_territory_id = new_hover_id
		
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			GameEvents.map_mouse_left_clicked.emit(hover_territory_id)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			GameEvents.map_mouse_right_clicked.emit(hover_territory_id)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			GameEvents.map_mouse_middle_clicked.emit(hover_territory_id)
	
	


