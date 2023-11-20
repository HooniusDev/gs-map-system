extends Node2D
class_name WorldMap

@onready var colors: Array[Color]

@onready var color_id_texture: Sprite2D = %Territories
var map_size: Vector2i

var selected_army: Army:
	get: return selected_army
	set (army):
		if selected_army:
			selected_army.set_unselected()
		if army:
			army.set_selected()
			mouse_state = MOUSE_STATES.Move
		else:
			mouse_state = MOUSE_STATES.Default
		selected_army = army
		
		
var allowed_move_territories: Array[int]

enum MOUSE_STATES { Default, Move }

var mouse_state: MOUSE_STATES = MOUSE_STATES.Default

func _ready() -> void:
	GameEvents.army_left_clicked.connect( _on_army_left_clicked )
	GameEvents.army_moved.connect(_on_army_moved)
	
	map_size = Vector2i( color_id_texture.get_rect().size.x, color_id_texture.get_rect().size.y )
	
	for node in color_id_texture.get_children():
		colors.append( node.self_modulate )
		
	for i in %Territories.get_child_count():
		%Territories.get_child(i).id = i 
		
func get_territory_by_id( id: int ) -> Node2D:
	return %Territories.get_child(id)

func get_id_by_color( color: Color ) -> int:
	for id in colors.size():
		if colors[id].is_equal_approx(color):
			return id
	return -1

func get_id_by_position( pos: Vector2 ) -> int:
	var local: Vector2 = pos + map_size / 2.0
	if local.x >= 0 and local.y >= 0 and local.x < color_id_texture.texture.get_width() and local.y < color_id_texture.texture.get_height():
		var color = color_id_texture.texture.get_image().get_pixelv( local )
		return get_id_by_color( color )
	return -1

func _on_hover_territory_changed( old_id: int, new_id: int ) -> void:
	if mouse_state == MOUSE_STATES.Move:
		return

	
func _on_left_click(territory_id: int) -> void:

	if territory_id == -1:
		selected_army = null
		return
	
	if mouse_state == MOUSE_STATES.Move:
		if allowed_move_territories.has(territory_id):
			selected_army.move_to( get_territory_by_id(territory_id) )
			$CanvasLayer/Messages.text = "Army moving to: " + get_territory_by_id(territory_id).name
			print("Army command: move")
		else:
			$CanvasLayer/Messages.text = "Army cant reach there!"
			print("Cant move there")
		return
	
	GameEvents.selected_territory_changed.emit(get_territory_by_id(territory_id))

	
func _on_middle_click(territory_id: int) -> void:
	print("map middle clicked ", territory_id)
	pass

func _on_right_click(territory_id: int) -> void:
	selected_army.set_unselected()
	selected_army = null
	print("map right clicked ", territory_id)
	pass
	
func _on_army_left_clicked( army: Army ):
	if selected_army:
		print("army deselected")
		# hide allowed moves
		for id in allowed_move_territories:
			var old_mask: Sprite2D = get_territory_by_id(id).get_node("Mask") as Sprite2D
			old_mask.material = null
			old_mask.z_index = 0
		selected_army.set_unselected()
		selected_army = null
		
	if army and selected_army != army:
		print("army selected")
		army.set_selected()
		allowed_move_territories = []
		for territory in army.territory.connections:
			allowed_move_territories.append( territory.id )
			GameEvents.move_allowed_list_changed.emit(allowed_move_territories)

	selected_army = army
	pass
	
func _on_army_moved( army: Army ):
	for id in allowed_move_territories:
		var old_mask: Sprite2D = get_territory_by_id(id).get_node("Mask") as Sprite2D
		old_mask.material = null
		old_mask.z_index = 0
	selected_army = null
	pass

func _on_child_entered_tree(node: Node) -> void:
	# Automatically setup Input node and signals
	if node is WorldMapInput:
		node.setup_input( self, %Territories )
		GameEvents.hover_territory_changed.connect(_on_hover_territory_changed)
		GameEvents.map_mouse_left_clicked.connect(_on_left_click)
		GameEvents.map_mouse_middle_clicked.connect(_on_middle_click)
		GameEvents.map_mouse_right_clicked.connect(_on_right_click)
	pass # Replace with function body.
