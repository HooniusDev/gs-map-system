extends Sprite2D

### Highlights territory

## TODO:
## Customizable colors
## Maybe use this class for Selected and Conquered
## Add a link to territory?



func _ready() -> void:
	MapEditor.hover_territory_changed.connect(_on_hover_territory_changed)

func _on_hover_territory_changed(id: int):
	%ColorID.set_sprite_to_territory(id, self)
#func set_to( _position: Vector2i, _texture: Texture ) -> void
	#position = _position
	#texture = _texture
	
#func hover( _position: Vector2i, _texture: Texture ) -> void:
	#position = _position
	#texture = _texture

