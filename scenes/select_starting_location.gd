extends Node

var selected: TerritoryData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #$ConfirmationDialog.canceled.connect(_on_cancel)
    #$ConfirmationDialog.confirmed.connect(_on_confirm)
    #get_parent().selected_territory_changed.connect(_selected_changed)
    pass # Replace with function body.

func _selected_changed( territory: TerritoryData ):
    selected = territory
    ## Show a gui to confirm
    $ConfirmationDialog.dialog_text = "Select "+ selected._name +" as your starting territory?"
    $ConfirmationDialog.show()
    $ConfirmationDialog.move_to_center()
    pass

func _on_confirm():
    print("Selected: " , selected._name)
    queue_free()
    pass
    
func _on_cancel():
    print("Cancels")
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
