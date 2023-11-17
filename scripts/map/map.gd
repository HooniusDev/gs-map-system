extends Node2D
class_name EditorMap

@onready var territories: Node2D = $Territories
@onready var images: Node2D = $Images

func _ready() -> void:
	MapEditorEvents.color_id_texture_changed.connect(create_territories)
	pass

func create_territories() -> void:
	print("Create_territories ")
	
	for t in territories.get_children():
		territories.remove_child(t)
		t.queue_free()
		
	## if id dont exist createa new TerritoryData 
	for i in Globals.Manager.color_id.colors.size():
		var territory = Territory.new()
		territories.add_child(territory)
		var data = TerritoryData.new()
		data.colorID = Globals.Manager.color_id.colors[i]
		data.ID = i
		data.name = "territory_" + str(i)
		territory.setup(i, data)

	print("territory count: ", territories.get_child_count())
	
	MapEditorEvents.territory_list_changed.emit()
