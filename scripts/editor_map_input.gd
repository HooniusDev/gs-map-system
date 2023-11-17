extends Area2D
class_name EditorMapInput

### Class to process all map related inputs ###

var highlight_on_hover: bool = true
var hover_id: int = -1
var focus_id: int = -1

### Adjust collisionshape size to match colorID size

func _ready() -> void:
	input_event.connect( on_input_event )
	
	pass

func on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:

	## Update Mouse Position
	var mouse_pos: Vector2i = get_local_mouse_position()
	print(mouse_pos)
	
	## If Left Clicked and Mouse Hovering over a Territory
	if event is InputEventMouseButton and event.is_released() and hover_id != -1:
		
		print("click ")
		
		## Set territory as selected
		focus_id = hover_id
		
		## Get the selected territory node
		
		#var territory = map_manager.get_territory_by_id(selected_territory_id)
		
		# TODO emit this for Global editor state to emit lost_focus on old one
		MapEditor.focus_territory_changed.emit(focus_id) #
		
		## Faction 0 gets to conquer the territory for now
		#$Factions.accuire_territory( 0, territory )
	
		
	if event is InputEventMouseMotion:
		
		var territory_id = $"../Images/ColorID".get_id_by_position( mouse_pos )
		#print(territory_id)
#
		### Mouse is not over a Territory
		if territory_id == -1:
			return
		##print("Mouse over map")
		### Mouse has just moved over a different Territory
		if territory_id != hover_id:
			
			hover_id = territory_id
			MapEditor.hover_territory_changed.emit(hover_id)
			$"../Images/ColorID".set_sprite_to_territory( hover_id, $"../Images/HoverVisualizer" )
