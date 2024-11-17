class_name TipsContainer
extends Control

@export var window_width: int

@onready var success_label: Label = $SuccessPanel/Margin/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var success_panel: PanelContainer = $SuccessPanel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_start_success_panel_position() -> void:
	success_panel.position = Vector2((window_width - success_panel.size.x) / 2, 30)
	var tween = create_tween()
	# 使用 Tween 动画在 1 秒内改变 Y 位置从 30 到 60
	tween.tween_property(success_panel, "position:y", 100, 1.0)
