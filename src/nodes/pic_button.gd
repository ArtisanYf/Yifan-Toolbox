class_name PicButton
extends Button

signal icon_changed(icon)

var custom_icon: Texture2D:
	set(v):
		custom_icon = v
		icon = custom_icon
		icon_changed.emit(icon)

func _ready() -> void:
	toggle_mode = true
	expand_icon = true
	icon_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
