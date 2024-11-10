class_name ConfirmationDialogBox
extends Window

signal confirm(params: Dictionary)

var params: Dictionary

@onready var confirm_button: Button = $Panel/Margin/V/H/ConfirmButton
@onready var cancel_button: Button = $Panel/Margin/V/H/CancelButton
@onready var content_label: Label = $Panel/Margin/V/ContentLabel
@onready var title_label: Label = $Panel/Margin/V/TitleLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	cancel_button.pressed.connect(func(): queue_free())
	confirm_button.pressed.connect(func(): 
		confirm.emit(params)
		queue_free()
	)


func init_scene(_params: Dictionary) -> void:
	params = _params
	if "title" in params:
		title_label.text = params.title
	if "content" in params:
		content_label.text = params.content
