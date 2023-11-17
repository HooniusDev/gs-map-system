extends Sprite2D

### Highlights territory

## TODO:
## Customizable colors
## Maybe use this class for Selected and Conquered
## Add a link to territory?



func _ready() -> void:
	MapEditorEvents.hover_territory_changed.connect(_on_hover_territory_changed)
	MapEditorEvents.color_id_texture_changed.connect( _color_id_changed )

func _on_hover_territory_changed(id: int):
	$"../ColorID".set_sprite_to_territory(id, self)
	if hidden:
		show()
#func set_to( _position: Vector2i, _texture: Texture ) -> void
	#position = _position
	#texture = _texture

func _color_id_changed() -> void:
	hide()

#func hover( _position: Vector2i, _texture: Texture ) -> void:
	#position = _position
	#texture = _texture

