extends StaticBody2D
class_name Map

@onready var colors: Array[Color]

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var color_id_texture: Sprite2D = $ColorID_Texture


func _ready() -> void:
	for node in $ColorID_Texture.get_children():
		colors.append( node.self_modulate )
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = color_id_texture.texture.get_size()
	collision_shape_2d.shape = shape


func get_id_by_color( color: Color ) -> int:
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

func get_id_by_position( pos: Vector2 ) -> int:
	var local: Vector2 = pos + collision_shape_2d.shape.get_size() / 2.0
	var color = color_id_texture.texture.get_image().get_pixelv( local )
	return get_id_by_color( color )

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	
	print("Mouse over: " , get_id_by_position( get_local_mouse_position() ) )

#func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#print("Mouse over: " , get_id_by_position( event.position ))
	#pass # Replace with function body.
