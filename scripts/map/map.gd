extends Node2D
class_name EditorMap

@onready var territories: Node2D = $Map/Territories
@onready var images: Node2D = $Map/Images

@export var color_id_path: String

func _ready() -> void:
	MapEditorEvents.load_color_id.connect( _on_load_color_id )
	MapEditorEvents.load_background.connect( on_load_background )

func on_load_background( path: String ) -> void:
	$Images/Background.texture = $Images/Background.load(path)
	pass

func _on_load_color_id( path: String ) -> void:
	if color_id_path != path:
		$Images/ColorID.load_texture(path)
		color_id_path = path
