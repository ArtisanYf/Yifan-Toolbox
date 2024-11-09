class_name MenuPanelButton
extends Button

## 菜单按钮面板

const THEME_TYPE = "MenuPanelButton"

func _ready() -> void:
	add_theme_stylebox_override("normal", get_theme_stylebox("normal", THEME_TYPE))
	add_theme_stylebox_override("hover", get_theme_stylebox("hover", THEME_TYPE))
	add_theme_stylebox_override("hover_pressed", get_theme_stylebox("hover", THEME_TYPE))
	add_theme_stylebox_override("pressed", get_theme_stylebox("normal", THEME_TYPE))
