@tool
extends TabContainer


func _enter_tree() -> void:
    get_node("/root/Preview").theme.emit_changed()
    
    #selected.emit_changed()
    #print( "_enter_tree selected: " , selected )
    pass
    
func _ready() -> void:
    var selected = get_theme_stylebox( "tab_selected" )
    print( "_ready selected: " , selected )
    

func _on_theme_changed() -> void:
    var selected = get_theme_stylebox( "tab_selected" )
    print( "_on_theme_changed selected: " , selected )

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_released():
        var selected = get_theme_stylebox( "tab_selected" )
        print( "_gui_input selected: " , selected )
    
    if event is InputEvent and event.is_action_released("ui_accept"):
        var selected = get_theme_stylebox( "tab_selected" )
        var _theme : Theme = get_tree().root.get_node("Preview").theme #.name
        print("theme:" , _theme.resource_name )
