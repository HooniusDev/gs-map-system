extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ZoomOut.pressed.connect(zoom_out)
	%ZoomIn.pressed.connect(zoom_in)
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	var set_as_handled = false
	if event.is_action_pressed("ui_left"):
		position = position + Vector2( -20, 0 )
		set_as_handled = true
	if event.is_action_pressed("ui_right"):
		position = position + Vector2( 20, 0 )
		set_as_handled = true
	if event.is_action_pressed("ui_up"):
		position = position + Vector2( 0, -20 )
		set_as_handled = true
	if event.is_action_pressed("ui_down"):
		position = position + Vector2( 0, 20 )
		set_as_handled = true
	if event.is_action_released("zoom_in"):
		#zoom = zoom + Vector2( .1, .1 )
		#zoom_camera( 0.1, event.position )
		zoom_again( 1 )
		set_as_handled = true
	if event.is_action_released("zoom_out"):
		#zoom = zoom - Vector2( .1, .1 )
		#zoom_camera( -0.1, event.position )
		zoom_again( -1 )
		set_as_handled = true

	if set_as_handled:
		get_viewport().set_input_as_handled()

func zoom_out():
	var previous_mouse_position := get_screen_center_position()
	zoom -= Vector2( .2, .2 ) 
	var diff = previous_mouse_position - get_screen_center_position()
	offset += diff

func zoom_in():
	var previous_mouse_position := get_screen_center_position()
	zoom += Vector2( .2, .2 ) 
	var diff = previous_mouse_position - get_screen_center_position()
	offset += diff
	
func zoom_again( dir: int ) -> void:
	var previous_mouse_position := get_local_mouse_position()
	#print (Vector2( .2 * dir, .2 * dir) )
	zoom += Vector2( .2 * dir, .2 * dir) 
	var diff = previous_mouse_position - get_local_mouse_position()
	offset += diff
	
func zoom_camera(zoom_factor, mouse_position):
	var viewport_size = get_viewport().size
	zoom += zoom + Vector2( zoom_factor, zoom_factor )
	position += ((viewport_size * 0.5) - to_local(mouse_position))
	
func zoom_at_mouse( zoom_change: float, position: Vector2 ):
	var c0 = global_position # camera position
	var v0 = get_viewport().size # vieport size
	var c1 # next camera position
	var z0 = zoom # current zoom value
	var z1 = z0 + Vector2( zoom_change, zoom_change ) # next zoom value

	c1 = c0 + (-0.5*v0 + position)*(z0 - z1)
	zoom = z1
	global_position = c1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
