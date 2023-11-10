extends TextEdit

@onready var grabber := get_child( 0, true )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var scroll = get_v_scroll_bar() as VScrollBar
    scroll.show()
    pass # Replace with function body.

func _draw() -> void:
    #draw_rect( grabber.get_clobal_rect(), Color.BLUE, true )
    pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
