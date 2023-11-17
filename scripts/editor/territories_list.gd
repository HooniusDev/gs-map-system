extends GridContainer

### TODO:
### Move the list item functions into items themself and handle adding 
### and removing in this one

const TERRITORY_LIST_ITEM = preload("res://scenes/editor/territory_list_item.tscn")

#var _highlighted: int
#
func _ready() -> void:
	MapEditor.territory_list_changed.connect(_update_list)
	#MapEditor.hover_territory_changed.connect( _highlight )
	#
#
#func _highlight( id: int ) -> void:
	## hide if there was some highlighted
	#if id == -1 and _highlighted >= 0:
		#get_child(_highlighted).get_node("Highlight").hide()
		#_highlighted = id
		#return
	## hide old
	#if id != _highlighted:
		#get_child(_highlighted).get_node("Highlight").hide()
		#get_child(id).get_node("Highlight").show()
	#_highlighted = id

func _update_list() -> void:
	
	### only delete and add if territorydata is new instance
	_clear()
	
	var t_array = MapEditor.edited_map.territories
	for t in t_array:
		#t.changed.connect( update_line.bind( t ) )
		var list_item = TERRITORY_LIST_ITEM.instantiate() as TerritoryListItem
		#list_item.mouse_entered.connect( _on_list_item_hover.bind( t.ID ) )
		add_child(list_item)
		list_item.link_to_territory( t )
		#update_line(t)
	pass
	
#func _on_list_item_hover( id:int ) -> void :
	#MapEditor.hover_territory_changed.emit( id )
	
	
#func update_line( territory_data: TerritoryData ) -> void:
	#get_child( territory_data.ID ).get_node("PanelContainer/ID").text = str(territory_data.ID)
	#var name_edit: LineEdit = get_child( territory_data.ID ).get_node("PanelContainer/Name") as LineEdit
	#if not name_edit.text_submitted.is_connected(_rename_territory):
		#name_edit.text_submitted.connect( _rename_territory.bind( territory_data) )
	#get_child( territory_data.ID ).get_node("PanelContainer/Name").text = territory_data.name
	#get_child( territory_data.ID ).get_node("PanelContainer/Color").color = territory_data.colorID
	#
func _rename_territory( name: String, territory_data: TerritoryData ) -> void:
	print("renaming territory: " , territory_data.ID)
	### Todo warn if name not unique
	territory_data.name = name

func _clear() -> void :
	print("Clear List")
	for node in get_children():
		#remove_child(node)
		node.queue_free()

