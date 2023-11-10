extends PanelContainer

## Info Panel


func _ready() -> void:
    get_node("/root/Main").selected_territory_changed.connect( _update )

## Updates the selected territory info
func _update( selected: Territory ):
    print("Updating info", selected.name)
    %Name.text = selected.name

    %Description.text = "This is a beautiful description of the territory"

