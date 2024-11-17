class_name VideoItemContainer
extends PanelContainer

signal change_cover_picture
signal right_click(id: int)

const VIDEO_ITEM_INFO_PANEL = preload("res://src/modules/local_video/video/video_item_info_panel.tscn")

var video_item: VideoItem = VideoItem.new():
	set(v):
		if v.video_name != video_item.video_name:
			name_label.text = v.video_name
		if v.create_time != video_item.create_time:
			time_label.text = v.create_time
		video_item = v
	
var is_loading_icon = false

## 封面图片
var cover_picture_texture: Texture:
	set(v):
		cover_picture_texture = v
		cover_picture.texture = cover_picture_texture
		change_cover_picture.emit()
		
@onready var cover_picture: TextureRect = $V/TextureMargin/CoverPicture
@onready var name_label: Label = $V/NameMargin/NameLabel
@onready var time_label: Label = $V/TimeMargin/TimeLabel
@onready var double_click_timer: Timer = $DoubleClickTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			# 双击切换场景
			if double_click_timer.is_stopped():
				double_click_timer.start()
			else:
				var video_info_panel := VIDEO_ITEM_INFO_PANEL.instantiate()
				get_tree().current_scene.add_child(video_info_panel)
				video_info_panel.init_scene(video_item)
				
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and event.pressed:
			right_click.emit(video_item.id)

# 初始化本场景
func init_scene(_video_item: VideoItem):
	video_item = _video_item
	#print(FFmpegUtil.get_video_info(SystemSettings.video_setting.ffprobe_path, video_item.video_path))
	change_cover_picture.connect(func():
		var shader_material := ShaderMaterial.new()
		# 加载本地 Shader 文件
		var shader_code = load("res://src/shaders/blur.gdshader")
		shader_material.shader = shader_code
		material = shader_material
		cover_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		material.set_shader_parameter("iChannel0", cover_picture_texture)
		material.set_shader_parameter("strength", 5)
		pass
	)

func refresh_video_item(_video_item: VideoItem) -> void:
	init_scene(_video_item)
	if video_item.cover_picture_path:
		cover_picture_texture = TextureUtil.create_texture(video_item.cover_picture_path)
	is_loading_icon = true
	
