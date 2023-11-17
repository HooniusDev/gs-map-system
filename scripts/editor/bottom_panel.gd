extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MapEditor.hover_territory_changed.connect( _update_hover_info )
	pass # Replace with function body.

func _update_hover_info( id: int ) -> void:
	$VBoxContainer/HoverID/Value.text = str(id)
	$VBoxContainer/HoverName/Value.text = MapEditor.edited_map.territories[id].name
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
