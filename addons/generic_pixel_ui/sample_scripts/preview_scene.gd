extends PanelContainer


func _enter_tree() -> void:
    #theme.emit_changed()
    pass
    
func _ready() -> void:
    
    ## ToolTip Offset
    var offset = ProjectSettings.get("display/mouse_cursor/tooltip_position_offset")
    %X_Spinbox.value = offset.x
    %Y_Spinbox.value = offset.y
    %X_Spinbox.value_changed.connect( _adjust_tooltip_offset )
    %Y_Spinbox.value_changed.connect( _adjust_tooltip_offset )
    
    ## Mouse Cursor Scale
    %"1X".button_up.connect( _mouse_scale.bind( 1 ) )
    %"2X".button_up.connect( _mouse_scale.bind( 2 ) )
    %"3X".button_up.connect( _mouse_scale.bind( 3 ) )
    %"4X".button_up.connect( _mouse_scale.bind( 4 ) )
    Input.set_custom_mouse_cursor(preload("res://addons/generic_pixel_ui/sprites/mouse/arrow_scale_4.png"))


    var popup: = PopupMenu.new()
    popup.add_check_item("Check ME")
    popup.add_item("just an item")
    popup.name = "FromCode"
    popup
    %MenuBar.add_child(popup)
    print( "Is 2 disabled? " , %MenuBar.is_menu_disabled(2) )
    

## Ignoring passed value and read both x and y to update
func _adjust_tooltip_offset( value : float ) -> void:
    var x = %X_Spinbox.value
    var y = %Y_Spinbox.value
    ProjectSettings.set("display/mouse_cursor/tooltip_position_offset", Vector2(x,y)) 

## Loads mouse .png based on value 1 - 4 
func _mouse_scale( scale : int):
    var cursor = load( "res://addons/generic_pixel_ui/sprites/mouse/arrow_scale_" + str(scale) + ".png" )
    Input.set_custom_mouse_cursor( cursor )
