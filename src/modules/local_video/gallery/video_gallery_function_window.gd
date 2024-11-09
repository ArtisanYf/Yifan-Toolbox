extends Window

@onready var title_label: Label = $PanelContainer/V/TitleMargin/TitleLabel
@onready var line_edit: LineEdit = $PanelContainer/V/EditMargin/LineEdit
@onready var confirm_button: Button = $PanelContainer/V/ExecuteMargin/H/ConfirmButton
@onready var cancel_button: Button = $PanelContainer/V/ExecuteMargin/H/CancelButton

func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	get_parent().modulate = Color(1, 1, 1, 0.5)
	line_edit.grab_focus()

func _exit_tree() -> void:
	get_parent().modulate = Color(1, 1, 1, 1)

func _on_cancel_button_pressed() -> void:
	queue_free()
