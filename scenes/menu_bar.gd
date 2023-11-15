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
		var file_dialog: FileDialog = $"../../FileDialog" as FileDialog
		file_dialog.popup_centered()
		file_dialog.mode_overrides_title = false
		file_dialog.title = "Load a Color ID Image"
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_dialog.set_filters(PackedStringArray(["*.png ; PNG Images"]))
		file_dialog.file_selected.connect( _on_load_color_id )

		
func _on_load_color_id( path: String ) -> void:
	%ColorID.load_texture( path )
	$"../../FileDialog".file_selected.disconnect(_on_load_color_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
