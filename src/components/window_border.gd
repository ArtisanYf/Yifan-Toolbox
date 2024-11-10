extends PanelContainer

const MAXIMIZE_1_32 = preload("res://assets/icon/maximize_1_32.png")
const MAXIMIZE_3_32 = preload("res://assets/icon/maximize_3_32.png")
var is_dragging = false  # 用来记录是否在拖动窗口

var drag_offset = Vector2i.ZERO  # 记录拖动的偏移量


@onready var window := get_tree().root
@onready var minimization_button: Button = $HEnd/MinimizationButton
@onready var maximize_button: Button = $HEnd/MaximizeButton
@onready var close_button: Button = $HEnd/CloseButton


func _ready():
	gui_input.connect(window_moving)
	# 连接按钮信号
	minimization_button.pressed.connect(_on_minimization_button_pressed)
	maximize_button.pressed.connect(_on_maximize_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	
# 窗口移动
func window_moving(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.pressed:
				# 鼠标左键按下，开始拖动
				is_dragging = true
				drag_offset = DisplayServer.mouse_get_position() - Vector2i(window.position)
			else:
				# 鼠标左键松开，停止拖动
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		if window.mode == Window.Mode.MODE_MAXIMIZED:
			var x: float = float(DisplayServer.mouse_get_position().x) / window.size.x
			window.mode = Window.Mode.MODE_WINDOWED
			drag_offset = Vector2i(int(window.size.x * x), 0)
			maximize_button.icon = MAXIMIZE_1_32
		window.position = DisplayServer.mouse_get_position() - drag_offset

# 最小化窗口
func _on_minimization_button_pressed():
	window.mode = Window.Mode.MODE_MINIMIZED

# 最大化或还原窗口
func _on_maximize_button_pressed():
	if window.mode != Window.Mode.MODE_MAXIMIZED:
		window.mode = Window.Mode.MODE_MAXIMIZED
		maximize_button.icon = MAXIMIZE_3_32
	else:
		window.mode = Window.Mode.MODE_WINDOWED
		maximize_button.icon = MAXIMIZE_1_32
		
# 关闭窗口
func _on_close_button_pressed():
	get_tree().quit()
