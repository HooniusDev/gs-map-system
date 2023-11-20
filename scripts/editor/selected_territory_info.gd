extends PanelContainer

## Info Panel


func _ready() -> void:
	GameEvents.selected_territory_changed.connect( _update )

## Updates the selected territory info
func _update( territory: Node2D ):
	if territory:
		$VBoxContainer/Name.text = territory.name
		$VBoxContainer/TextureRect.texture = territory.get_node("BG").texture
		$VBoxContainer/Armies.text = "Armies Here"
		$VBoxContainer/Faction.text = "Owner ID "
		$VBoxContainer/Misc.text = "Misc info"
		#%Description.text = "This is a beautiful description of the territory"
	else: 
		$VBoxContainer/Name.text = "N/A"
		$VBoxContainer/TextureRect.texture = null
		$VBoxContainer/Armies.text = "N/A"
		$VBoxContainer/Faction.text = "N/A"
		$VBoxContainer/Misc.text = "N/A"
	

