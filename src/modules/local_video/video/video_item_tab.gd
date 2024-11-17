class_name VideoItemTab
extends PopupPanel

var id: int

var button_group := ButtonGroup.new()

@onready var v: VBoxContainer = $FunctionMargin/V
@onready var play_button: Button = $FunctionMargin/V/PlayButton
@onready var open_location_button: Button = $FunctionMargin/V/OpenLocationButton
@onready var open_location_tab_panel: PopupPanel = $OpenLocationTabPanel
@onready var open_video_button: Button = $OpenLocationTabPanel/FunctionMargin/V/OpenVideoButton
@onready var open_poster_button: Button = $OpenLocationTabPanel/FunctionMargin/V/OpenPosterButton
@onready var open_preview_button: Button = $OpenLocationTabPanel/FunctionMargin/V/OpenPreviewButton
@onready var replace_cover_button: Button = $FunctionMargin/V/ReplaceCoverButton
@onready var delete_button: Button = $FunctionMargin/V/DeleteButton
@onready var expand_function_button: Button = $FunctionMargin/V/ExpandFunctionButton
@onready var expand_function_tab_panel: PopupPanel = $ExpandFunctionTabPanel
@onready var generate_screenshot_button: Button = $ExpandFunctionTabPanel/FunctionMargin/V/GenerateScreenshotButton



func _ready() -> void:
	for button in v.get_children():
		if button is Button:
			button.button_group = button_group
			button.toggle_mode = true
			button.mouse_entered.connect(func(): button.button_pressed = true)
	
	button_group.pressed.connect(func(button: Button):
		if open_location_tab_panel.visible == true:
			open_location_tab_panel.visible = false
		if expand_function_tab_panel.visible == true:
			expand_function_tab_panel.visible = false
		if button.name == "OpenLocationButton":
			show_open_location_tab_panel()
		if button.name == "ExpandFunctionButton":
			show_open_expand_function_tab_panel()
	)
	
func show_open_location_tab_panel():
	open_location_tab_panel.visible = true
	open_location_tab_panel.position = Vector2(
		position.x + open_location_button.position.x + open_location_tab_panel.size.x + 25,
		position.y + open_location_button.position.y + 10
	)

func show_open_expand_function_tab_panel():
	expand_function_tab_panel.visible = true
	expand_function_tab_panel.position = Vector2(
		position.x + expand_function_button.position.x + expand_function_tab_panel.size.x + 25,
		position.y + expand_function_button.position.y + 10
	)
