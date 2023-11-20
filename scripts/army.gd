extends Area2D
class_name Army

var territory: Node2D

func _ready() -> void:
	move_to($"../../Territories/Cornwall")

func move_to( target: Node2D ):
	global_position = target.get_node("Crest").global_position
	territory = target
	GameEvents.army_moved.emit(self)
	
func set_selected() -> void:
	$ColorRect.show()

func set_unselected() -> void:
	$ColorRect.hide()

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	viewport.set_input_as_handled()
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			GameEvents.army_left_clicked.emit(self)
