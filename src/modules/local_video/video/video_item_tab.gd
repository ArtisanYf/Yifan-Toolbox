extends PopupPanel

var id: int

var button_group := ButtonGroup.new()

@onready var play_button: Button = $FunctionMargin/V/PlayButton
@onready var open_location_button: Button = $FunctionMargin/V/OpenLocationButton
@onready var show_timer: Timer = $ShowTimer
@onready var open_location_tab_panel: PopupPanel = $OpenLocationTabPanel
@onready var v: VBoxContainer = $FunctionMargin/V


func _ready() -> void:
	for button in v.get_children():
		if button is TabButton:
			button.button_group = button_group
			button.toggle_mode = true
			button.mouse_entered.connect(func(): button.tab_button_pressed = true)

	open_location_button.pressed.connect(func(): show_open_location_tab_panel())
	open_location_button.change_tab_button_pressed.connect(func(v):
		if not v:
			open_location_tab_panel.visible = false
	)
	show_timer.timeout.connect(_on_open_location_timer_timeout)
	
func show_open_location_tab_panel():
	open_location_tab_panel.visible = true
	open_location_tab_panel.position = Vector2(
		position.x + open_location_button.position.x + open_location_tab_panel.size.x + 5,
		position.y + open_location_button.position.y + 10
	)

func _on_open_location_timer_timeout() -> void:
	show_open_location_tab_panel()
