class_name VideoGalleryTab
extends PopupPanel

signal rename(id: int)
signal delete(id: int)
signal set_picture(id: int)

var id: int

@onready var function_margin: MarginContainer = $FunctionMargin
@onready var set_picture_button: Button = $FunctionMargin/V/SetPictureButton
@onready var rename_button: Button = $FunctionMargin/V/RenameButton
@onready var open_button: Button = $FunctionMargin/V/OpenButton
@onready var delete_button: Button = $FunctionMargin/V/DeleteButton



func _ready() -> void:
	open_button.pressed.connect(_on_open_button_pressed)
	rename_button.pressed.connect(_on_rename_button_pressed)
	set_picture_button.pressed.connect(_on_set_picture_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)
	
func _on_open_button_pressed() -> void:
	visible = false
	
func _on_rename_button_pressed() -> void:
	rename.emit(id)
	visible = false
	
func _on_set_picture_pressed() -> void:
	visible = false
	set_picture.emit(id)
	
func _on_delete_button_pressed() -> void:
	delete.emit(id)
	visible = false
