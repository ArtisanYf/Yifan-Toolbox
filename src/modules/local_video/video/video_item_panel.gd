class_name VideoPanel
extends VBoxContainer

const VIDEO_ITEM_CONTAINER = preload("res://src/modules/local_video/video/video_item_container.tscn")
@onready var search_line_edit: LineEdit = $SearchMargin/H/SearchLineEdit
@onready var add_button: Button = $SearchMargin/H/AddButton
@onready var number_label: Label = $FunctionMargin/H/NumberLabel
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var h_flow: HFlowContainer = $ScrollContainer/HFlow


func _ready() -> void:
	VideoItemService.change_video_item_array.connect(_on_change_video_item_array)
	scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_scroll_bar_value_changed)
	add_button.pressed.connect(_on_add_button_pressed)
	refresh_video_item_all()

# 更新视频库容器
func refresh_video_item_all(search_name: String = search_line_edit.text) -> void:
	# 删除所有子节点
	for node in h_flow.get_children():
		node.queue_free()
	
	if not VideoGalleryService.current_video_gallery:
		return
	
	var video_item_array := VideoItemService.select_array(
		QueryBuilder.new()
		.select(["*"])
		.eq("video_gallery_id", VideoGalleryService.current_video_gallery.id)
		.like("video_name", search_name, search_name != "")
		.orderByDesc("create_time")
	)
	var count: int = 0
	for video_item: VideoItem in video_item_array:
		instantiate_video_item(video_item)
		count += 1
	number_label.text = str(count) + "/" + str(video_item_array.size())
	await get_tree().process_frame
	_on_v_scroll_bar_value_changed(0)

# 实例化场景	
func instantiate_video_item(video_item: VideoItem) -> VideoItemContainer:
		var video_item_scene = VIDEO_ITEM_CONTAINER.instantiate()
		# 将实例化的场景添加到父节点
		h_flow.add_child(video_item_scene)
		# 初始化传参
		video_item_scene.init_scene(video_item)
		#video_item_scene.right_click.connect(_on_gallery_right_click)
	
		return video_item_scene


func _on_add_button_pressed() -> void:
	DisplayServer.file_dialog_show(
	"选择视频", "", "", false,
	DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
	["*.mp4,*.avi"],
	func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		if selected_paths.is_empty():
			return
		# 检测视频
		var video_path := selected_paths[0]
		var cover_path := FFmpegUtil.get_video_first_frame(
			SystemSettings.get_ffmpeg_path(),
			video_path,
			VideoItemService.COVER_PICTURE_PATH
		)
		var video_item := VideoItem.new()
		video_item.video_gallery_id = VideoGalleryService.current_video_gallery.id
		video_item.video_path = selected_paths[0]
		video_item.video_name = video_path.get_file().get_basename()
		video_item.cover_picture_path = cover_path
		video_item.create_time = DateUtil.format_current_time()
		VideoItemService.insert(video_item)
	)

func _on_v_scroll_bar_value_changed(value: float) -> void:
	var v_scroll_bar := scroll_container.get_v_scroll_bar()
	var current_value = value + v_scroll_bar.page
	var nodes := [] # 节点数组
	var datas := [] # 节点对应的数据数组
	for panel: VideoItemContainer in h_flow.get_children():
		# 检查PanelContainer是否在视口范围内
		if not panel.is_loading_icon and panel.position.y < current_value:
			panel.is_loading_icon = true
			if panel.video_item.cover_picture_path != "":
				nodes.append(panel)
				datas.append({ "cover_picture_path" = panel.video_item.cover_picture_path})
	if not nodes.is_empty():
		Task.add_task(
			Task.Task_Type.LOAD_TEXTURE,
			{
				"nodes" = nodes,
				"datas" = datas,
				"texture_field" = "cover_picture_path",
				"texture_property" = "cover_picture_texture",
			}
		)

func _on_change_video_item_array(type: VideoItemService.Change_Array_Type, video_item: VideoItem) -> void:
	match type:
		VideoGalleryService.Change_Array_Type.SAVE:
			var arr = number_label.text.split("/")
			var video_item_container := instantiate_video_item(video_item)
			video_item_container.refresh_video_item(video_item)
			number_label.text = str(int(arr[0]) + 1) + "/" + str(int(arr[1]) + 1)
			h_flow.move_child(h_flow.get_child(h_flow.get_child_count() - 1), 0)
			
		VideoGalleryService.Change_Array_Type.UPDATE:
			for node: VideoItemContainer in h_flow.get_children():
				if node.video_item.id == video_item.id:
					video_item = VideoItemService.select_one(QueryBuilder.new().eq("id", video_item.id))
					if video_item:
						node.refresh_video_item(video_item)
						
		VideoGalleryService.Change_Array_Type.DELETE:
			for node: VideoItemContainer in h_flow.get_children():
				if node.video_item.id == video_item.id:
					node.queue_free()
					var arr = number_label.text.split("/")
					number_label.text = str(int(arr[0]) - 1) + "/" + str(int(arr[1]) - 1)
