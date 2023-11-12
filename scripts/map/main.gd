extends StaticBody2D
class_name Main

### NOT USED AT THE MOMENT!
## WILL BE REPLACED WITH EDITOR SCRIPT
## MAP HANDLES ITS OWN STATE AND INPUT
## ENOUGH WITH THE CAPS!!! REALLY...

signal selected_territory_changed

var hover_territory_id: int = -1
var selected_territory_id: int = -1
			
@onready var map_manager: MapManager = $MapManager as MapManager
	
func input_event(viewport: Node, event: InputEvent, shape_idx: int):
	
	## Update Mouse Position
	var mouse_pos: Vector2i = get_local_mouse_position().round()
	
	## If Left Clicked and Mouse Hovering over a Territory
	if event is InputEventMouseButton and event.is_released() and hover_territory_id != -1:
		
		## Set territory as selected
		selected_territory_id = hover_territory_id
		
		## Get the selected territory node
		var territory = map_manager.get_territory_by_id(selected_territory_id)
		
		selected_territory_changed.emit(territory)
		
		## Faction 0 gets to conquer the territory for now
		$Factions.accuire_territory( 0, territory )
	
		
	if event is InputEventMouseMotion:
		
		var territory_id = map_manager.get_territory_id_by_position( mouse_pos )
		
		## Mouse is not over a Territory
		if territory_id == -1:
			return
		
		## Mouse has just moved over a different Territory
		if territory_id != hover_territory_id:
			#print("Mouse over: ", hover_territory_id)
			
			## Territory that becomes highlighted
			map_manager.get_territory_by_id(territory_id).on_mouse_enter()
			## Territory that becomes was highlighted
			map_manager.get_territory_by_id(hover_territory_id).on_mouse_exit()

		# Update current hover Territory 
		hover_territory_id = territory_id
		
		## OLD SHIT
		#var territory = territories.get_child(territory_id)
			#
		#if territory.data == mouse_over_territory or !is_instance_valid(territory):
			#return
		#else:
			#mouse_over_territory = territory.data
		#for node in territories.get_children():
			#if node.data == selected_territory_id:
				#continue
			#node.get_node("Mask").visible = false
		#if is_instance_valid(territory):
		#
			#var mask = territories.get_node(territory.data._name + "/Mask")
			#if is_instance_valid(mask):
				#mask.visible = true
		#print("Mouse [" , mouse_pos ,   "] Over: ", territory.data._name )

	

 

	

