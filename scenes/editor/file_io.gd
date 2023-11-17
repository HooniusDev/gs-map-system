extends Control

func _ready() -> void:
	MapEditorEvents.load_background.connect( _on_load_background )
	MapEditorEvents.load_color_id.connect( _on_load_color_id )
	pass

func _on_load_background():
	# show filedialog
	%LoadImageDialog.show()
	# wait for selection
	var path = await %LoadImageDialog.file_selected
	# set to bg
	$"../../Map/Images/Background".texture = load(path)
	pass
	
func _on_load_color_id():
	# show filedialog
	%LoadImageDialog.show()
	# wait for selection
	var path = await %LoadImageDialog.file_selected
	# set to bg
	$"../../Map/Images/ColorID".load_texture(path)
	pass
