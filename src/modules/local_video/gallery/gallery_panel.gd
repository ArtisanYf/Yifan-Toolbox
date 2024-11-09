extends VBoxContainer

const VIDEO_GALLERY_FUNCTION_WINDOW = preload("res://src/modules/local_video/gallery/video_gallery_function_window.tscn")
const VIDEO_GALLERY_ITEM = preload("res://src/modules/local_video/gallery/video_gallery_item.tscn")

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var v: VBoxContainer = $ScrollContainer/V
@onready var create_button: Button = $SearchMargin/H/CreateButton
@onready var search_line_edit: LineEdit = $SearchMargin/H/SearchLineEdit

func _ready():
	var v_scroll_bar := scroll_container.get_v_scroll_bar()
	v_scroll_bar.value_changed.connect(_on_v_scroll_bar_value_changed)
	create_button.pressed.connect(_on_create_button_pressed)
	refresh_video_gallery()
	
	
# 更新视频库容器
func refresh_video_gallery(search_name: String = search_line_edit.text) -> void:
	# 删除所有子节点
	for node in v.get_children():
		node.queue_free()
	
	var video_gallery_array = VideoGalleryService.select_rows()
	
	var count: int = 0
	for video_gallery in video_gallery_array:
		if search_name != "":
			if video_gallery.video_gallery_name.containsn(search_name):
				count = instantiate_video_gallery(count, video_gallery)
		else:
			count = instantiate_video_gallery(count, video_gallery)
			
# 实例化场景	
func instantiate_video_gallery(count: int, video_gallery: Dictionary) -> int:
		var video_gallery_item = VIDEO_GALLERY_ITEM.instantiate()
		# 将实例化的场景添加到父节点
		v.add_child(video_gallery_item)
		# 初始化传参
		video_gallery_item.init_video_gallery(video_gallery)
		count += 1
		return count

func _on_v_scroll_bar_value_changed(value: float) -> void:
	var v_scroll_bar := scroll_container.get_v_scroll_bar()
	var current_value = value + v_scroll_bar.page

	for panel in v.get_children():
		var panel_y = panel.position.y
		# 检查PanelContainer是否在视口范围内
		if not panel.is_loading_icon and panel_y < current_value:
			panel.is_loading_icon = true

func _on_create_button_pressed() -> void:
	var video_gallery_function_window := VIDEO_GALLERY_FUNCTION_WINDOW.instantiate()
	get_tree().current_scene.add_child(video_gallery_function_window)
	
	
