extends PopupPanel

signal rename(id: int)
signal delete(id: int)
signal set_picture(id: int)

var id: int

@onready var set_picture_button: Button = $Margin/V/SetPictureButton
@onready var rename_button: Button = $Margin/V/RenameButton
@onready var open_button: Button = $Margin/V/OpenButton
@onready var delete_button: Button = $Margin/V/DeleteButton

#
#const VIDEO_GALLERY_TAB_ITEM = preload("res://src/modules/videoGallery/video_gallery_tab_item.tscn")
#
#var video_library :Dictionary
#@onready var m: MarginContainer = $PanelContainer/MarginContainer
#@onready var v: VBoxContainer = $PanelContainer/MarginContainer/V
#@onready var p: PanelContainer = $PanelContainer
#
#
func _ready() -> void:
	open_button.pressed.connect(_on_open_button_pressed)
	rename_button.pressed.connect(_on_rename_button_pressed)
	set_picture_button.pressed.connect(_on_set_picture_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	
func _on_open_button_pressed() -> void:
	set_picture.emit(id)
	visible = false
	
func _on_rename_button_pressed() -> void:
	rename.emit(id)
	visible = false
	
func _on_set_picture_pressed() -> void:
	set_picture.emit(id)
	visible = false
	
func _on_delete_button_pressed() -> void:
	set_picture.emit()
	visible = false
