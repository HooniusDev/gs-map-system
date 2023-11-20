extends Node2D
class_name Territory

@export var connections: Array[Node2D]

@export var id: int = -1

@export var vassals: int
@export var income: int

enum VISUAL_STATES { Default, Hover, Selected, AllowMove }
var visual_state: VISUAL_STATES = VISUAL_STATES.Default

const HOVER_SHADER = preload("res://assets/shaders/hover_shader.tres")
const ALLOW_MOVE_SHADER = preload("res://assets/shaders/allow_move_shader.tres")
const SELECTED_SHADER = preload("res://assets/shaders/selected_shader.tres")

var faction_id: int = -1

func _ready() -> void:
	GameEvents.move_allowed_list_changed.connect(_on_move_allowed_list_changed)
	GameEvents.hover_territory_changed.connect(_on_hover_territory_changed)

func _on_move_allowed_list_changed( list: Array[int] ):
	var mask = get_node("Mask") as Sprite2D
	if list.has(id):
		visual_state = VISUAL_STATES.AllowMove
		mask.material = ALLOW_MOVE_SHADER
		mask.z_index = 1
		mask.self_modulate.a = 0.2
	else:
		visual_state = VISUAL_STATES.Hover
		mask.material = null
		mask.z_index = 0
	pass
	
func _on_hover_territory_changed( id: int ) -> void:
	var mask = get_node("Mask") as Sprite2D
	if self.id == id and  visual_state != VISUAL_STATES.AllowMove:
		visual_state = VISUAL_STATES.Hover
		mask.material = HOVER_SHADER
		mask.z_index = 1
		mask.self_modulate.a = 0.3
		return
	if self.id != id and visual_state == VISUAL_STATES.Hover:
		mask.material = null
		mask.z_index = 0
		mask.self_modulate.a = 0.0
	
