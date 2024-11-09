extends PanelContainer

const THEME_TYPE = "VideoGalleryItem"

var styles_box: StyleBoxFlat
var is_loading_icon = false
@onready var icon: TextureRect = $H/Margin/Icon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pass

#
#func _gui_input(event: InputEvent) -> void:
	#print(0)



func _on_mouse_entered() -> void:
	styles_box = get_theme_stylebox("panel", THEME_TYPE)
	add_theme_stylebox_override("panel", get_theme_stylebox("hover", THEME_TYPE))

func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", styles_box)
	#double_click_timer.stop()
