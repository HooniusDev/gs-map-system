extends MenuBar

@onready var sprite_menu: PopupMenu = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_menu.id_pressed.connect( _on_sprite_menu_pressed )
	pass # Replace with function body.

func _on_sprite_menu_pressed( id: int ) -> void:
	### Warn user if there is already a ColorID ###
	### TODO: Implement New Map functionality ###
	print("sprite menu pressed: " , sprite_menu.get_item_text(id) )
	if ( id == 0 ):
		MapEditorEvents.load_color_id.emit()
	if ( id == 1 ):
		MapEditorEvents.load_background.emit()

#func _on_load_background( path: String ) -> void:
	#MapEditorEvents.load_background.emit(path)
	##%ColorID.load_texture( path )
	#%FileDialog.file_selected.disconnect(_on_load_background)
		#
#func _on_load_color_id( path: String ) -> void:
	#MapEditorEvents.load_color_id.emit(path)
	##%ColorID.load_texture( path )
	#%FileDialog.file_selected.disconnect(_on_load_color_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
