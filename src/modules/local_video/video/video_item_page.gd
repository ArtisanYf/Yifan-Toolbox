extends Control

const HOME = "res://src/modules/home/home.tscn"
@onready var home_button: Button = $V/H/MenuPanel/V/Margin/H/HomeButton

func _ready() -> void:
	home_button.pressed.connect(_on_home_button_pressed)

func _on_home_button_pressed() -> void:
	var tree := get_tree()
	VideoGalleryService.current_video_gallery = null
	tree.change_scene_to_file(HOME)
