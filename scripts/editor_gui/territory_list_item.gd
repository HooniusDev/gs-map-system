extends PanelContainer
class_name TerritoryListItem

### List item in TerritoryList Updates on Data changes

### TODO: Add selected state

var _id: int = -1

func link_to_territory( data: TerritoryData ) -> void: 
	_id = data.ID
	data.changed.connect( _on_data_changed.bind( data ) )
	MapEditor.hover_territory_changed.connect( _on_hover_territory_changed )
	_update( data )
	mouse_entered.connect( _on_mouse_enter )
	mouse_exited.connect( _on_mouse_exit )
	
func _on_data_changed( data: TerritoryData ) -> void:
	print("Updating territory list item ", _id)
	pass

func _update( data: TerritoryData ) -> void:
	$PanelContainer/ID.text = data.get_id_as_string()
	$PanelContainer/Name.text = data.name
	$PanelContainer/Color.color = data.colorID

func _on_mouse_enter() -> void:
	#print( "Mouse enter: ", _id )
	$Highlight.show()
	## Highlights territory on map view
	MapEditor.hover_territory_changed.emit(_id)

func _on_mouse_exit() -> void:
	#print( "Mouse exit: ", _id )
	$Highlight.hide()

func _on_hover_territory_changed( id: int ) -> void:
	if id == _id:
		#print("Highlighting territory list item ", _id)
		$Highlight.show()
	else:
		$Highlight.hide()
