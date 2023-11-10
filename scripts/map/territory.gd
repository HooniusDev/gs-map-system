extends Node2D
class_name Territory

## Node Container for Territory

## Index in the Territory node 
var id: int = -1

## Has Mask Sprite2D as child
@onready var highlight_overlay: Sprite2D = $HighlightOverlay
@onready var faction_overlay: Sprite2D = $FactionOverlay

@export var data: TerritoryData

## Faction Colors
var _outline_color: Color = Color(0, 0, 0, 0.7)
var _fill_color: Color = Color(1, 1, 1, 0.345)

## Returns true if queried color matches territory Color ID
func is_color( color: Color ) -> bool:
    if data._color.is_equal_approx( color ):
        return true
    else:
        return false
    
func on_conquered( factionID: int ) -> void:
    
    if $FactionOverlay.texture == null:
        faction_overlay.texture = ImageTexture.create_from_image( data._mask )
    
    data.owner_id = factionID

    faction_overlay.visible = true
    faction_overlay.material.set_shader_parameter("outline_color", _outline_color)
    faction_overlay.material.set_shader_parameter("fill_color", _fill_color)
    
    

func on_mouse_enter():
    #print("mouse enter ", name)
    highlight_overlay.visible = true
    highlight_overlay.material.set_shader_parameter("outline_color", Color(0, 0, 0, 0.7))
    highlight_overlay.material.set_shader_parameter("fill_color", Color(1, 1, 1, 0.345))

func on_mouse_exit():
    highlight_overlay.visible = false
    #print("mouse exit ", name)
    #mask.material.set_shader_parameter("outline_color", _outline_color.a * .5)
    #mask.material.set_shader_parameter("fill_color", _fill_color.a * .5)


