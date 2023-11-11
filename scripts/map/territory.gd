@tool
extends Node2D
class_name Territory

## Node Container for Territory

## Index in the Territory node 
@export var id: int = -1

## Has Mask Sprite2D as child
@onready var highlight_overlay: Sprite2D = $HighlightOverlay
@onready var faction_overlay: Sprite2D = $FactionOverlay
@onready var crest: Sprite2D = $Crest

@export var colorID: Color


func _ready() -> void:
	owner = get_tree().edited_scene_root
	for node in get_children(  ):
		node.owner = get_tree().edited_scene_root



func setup( texture : ImageTexture, color_id: Color, _crest: Texture2D ):
	
	#for node in get_children(  ):
		#node.owner = get_tree().edited_scene_root
	
	highlight_overlay.texture = texture
	highlight_overlay.centered = false
	highlight_overlay.visible = true
	faction_overlay.texture = texture
	faction_overlay.centered = false
	faction_overlay.visible = false
	colorID = color_id
	if _crest:
		#print(highlight_overlay.texture.get_size()
		$Crest.position = highlight_overlay.texture.get_size() / 2.0
		$Crest.texture = _crest
		$Crest.centered = false
		$Crest.region_enabled = true
		$Crest.region_rect = $"../../../Crest".region_rect
	#set_editable_instance(self, true)

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


