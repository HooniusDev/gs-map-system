extends PanelContainer
class_name Manager

@onready var confirmation_dialog: ConfirmationDialog = $CanvasLayer/ConfirmationDialog

@onready var territories: Node2D = $Map/Territories
@onready var map: EditorMap = $Map
@onready var color_id: ColorID = $Map/Images/ColorID


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.Manager = self
	MapEditorEvents.color_id_texture_changed.connect( _on_color_id_texture_changed )
	pass # Replace with function body.

func _on_color_id_texture_changed() -> void:
	if territories.get_child_count() == 0:
		# Create new territories
		map.create_territories()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
