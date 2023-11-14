extends VBoxContainer

const TERRITORY_LIST_ITEM = preload("res://scenes/editor/territory_list_item.tscn")

var _highlighted: int

func _ready() -> void:
	MapEditor.territory_list_changed.connect(_update_list)
	MapEditor.hover_territory_changed.connect( _highlight )
	

func _highlight( id: int ) -> void:
	# hide if there was some highlighted
	if id == -1 and _highlighted >= 0:
		get_child(_highlighted).get_node("Highlight").hide()
		_highlighted = id
		return
	# hide old
	if id != _highlighted:
		get_child(_highlighted).get_node("Highlight").hide()
		get_child(id).get_node("Highlight").show()
	_highlighted = id

func _update_list() -> void:
	
	_clear()
	
	var t_array = MapEditor.edited_map.territories
	for t in t_array:
		t.changed.connect( update_line.bind( t ) )
		var list_item = TERRITORY_LIST_ITEM.instantiate()
		list_item.get_node("PanelContainer/ID").text = str(t.ID)
		list_item.get_node("PanelContainer/Name").text = t.name
		list_item.get_node("PanelContainer/Color").color = t.colorID
		add_child(list_item)
	pass
	
func update_line( territory_data: TerritoryData ) -> void:
	#print("updating line [ " , index, " ]")
	get_child( territory_data.ID ).get_node("PanelContainer/Name").text = territory_data.name
	

func _clear() -> void :
	print("Clear List")
	for node in get_children():
		remove_child(node)
		node.queue_free()

