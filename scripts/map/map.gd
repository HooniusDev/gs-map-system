extends StaticBody2D
class_name Map

@onready var colors: Array[Color]

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var color_id_texture: Sprite2D = $ColorID_Texture

const HOVER_SHADER = preload("res://assets/shaders/hover_shader.tres")

var hover_territory_id: int = -1

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
	if local.x >= 0 and local.y >= 0 and local.x < color_id_texture.texture.get_width() and local.y < color_id_texture.texture.get_height():
		var color = color_id_texture.texture.get_image().get_pixelv( local )
		return get_id_by_color( color )
	
	return -1

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	
	var id = get_id_by_position( get_local_mouse_position() )
	if (id == -1):
		return
	
	if event is InputEventMouseMotion:

		if id != hover_territory_id:
			var new_mask: Sprite2D = color_id_texture.get_child(id).get_node("Mask")
			print( id , ": ", new_mask.name )
			new_mask.material = HOVER_SHADER
			new_mask.z_index = 1
			var old_mask: Sprite2D = color_id_texture.get_child(hover_territory_id).get_node("Mask") as Sprite2D
			old_mask.material = null
			old_mask.z_index = 0
		hover_territory_id = id
		
	


