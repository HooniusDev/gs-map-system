extends Node

## signal when mouse hover territory has changed, ( old_id, new_id )
signal hover_territory_changed
signal move_allowed_list_changed

## parameter{territory: Node2D}
signal selected_territory_changed( territory: Node2D )
signal map_mouse_left_clicked
signal map_mouse_right_clicked
signal map_mouse_middle_clicked

signal army_left_clicked
signal army_moved
