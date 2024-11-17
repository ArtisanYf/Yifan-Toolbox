class_name VideoPanel
extends VBoxContainer

const VIDEO_ITEM_CONTAINER = preload("res://src/modules/local_video/video/video_item_container.tscn")

# 下次显示时是否需要刷新
var next_show_refresh := false

@onready var search_line_edit: LineEdit = $SearchMargin/H/SearchLineEdit
@onready var add_button: Button = $SearchMargin/H/AddButton
@onready var import_video_button: Button = $SearchMargin/H/ImportVideoButton
@onready var number_label: Label = $FunctionMargin/H/NumberLabel
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var h_flow: HFlowContainer = $ScrollContainer/HFlow
@onready var video_item_tab: VideoItemTab = $VideoItemTab
@onready var h_slider: HSlider = $BottomHBox/HSlider
@onready var random_show_button: Button = $FunctionMargin/H/RandomShowButton
@onready var search_button: Button = $SearchMargin/H/SearchLineEdit/SearchButton

func _ready() -> void:
	# 连接信号 --------
	VideoGalleryService.change_current_video_gallery.connect(_on_change_current_video_gallery)
	VideoItemService.change_video_item_array.connect(_on_change_video_item_array)
	
	visibility_changed.connect(_on_visibility_changed)
	
	scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_scroll_bar_value_changed)
	
	search_button.pressed.connect(func(): refresh_video_item_all())
	add_button.pressed.connect(_on_add_button_pressed)
	import_video_button.pressed.connect(_on_import_video_button_pressed)
	random_show_button.pressed.connect(func(): refresh_video_item_all(search_line_edit.text, true))
	search_line_edit.text_submitted.connect(_on_search_line_edit_text_submitted)
	
	
	video_item_tab.play_button.pressed.connect(_on_play_button_pressed)
	video_item_tab.open_video_button.pressed.connect(_on_open_video_button_pressed)
	video_item_tab.open_poster_button.pressed.connect(_on_open_poster_button_pressed)
	video_item_tab.open_preview_button.pressed.connect(_on_open_preview_button_pressed)
	
	video_item_tab.generate_screenshot_button.pressed.connect(_on_generate_screenshot_button_pressed)
	
	video_item_tab.replace_cover_button.pressed.connect(_on_replace_cover_button_pressed)
	video_item_tab.delete_button.pressed.connect(_on_delete_button_pressed)
	
	h_slider.value_changed.connect(func(value): 
		for node in h_flow.get_children():
			node.cover_picture.custom_minimum_size = Vector2(252 + value * 16, 141.75 + value * 9)
			node.custom_minimum_size = Vector2(256 + value * 16, 280 + value * 9)
		_on_v_scroll_bar_value_changed(0)
	)
	refresh_video_item_all()

# 更新视频库容器
func refresh_video_item_all(search_name: String = search_line_edit.text, is_random_show: bool = false) -> void:
	scroll_container.get_v_scroll_bar().value = 0
	# 删除所有子节点
	for node in h_flow.get_children():
		node.queue_free()
	
	if not VideoGalleryService.current_video_gallery:
		return
	
	# 构建查询
	var query_builder := QueryBuilder.new()
	query_builder.select(["*"])
	query_builder.eq("video_gallery_id", VideoGalleryService.current_video_gallery.id)
	query_builder.like("video_name", search_name, search_name != "")
	if is_random_show:
		query_builder.orderByRandom()
	else:
		query_builder.orderByDesc("create_time")
	var video_item_array := VideoItemService.select_array(query_builder)
	
	var count: int = 0
	for video_item: VideoItem in video_item_array:
		instantiate_video_item(video_item)
		if is_random_show and "preview_path" in video_item and video_item["preview_path"]:
			var files := DirAccess.get_files_at(video_item.preview_path)
			if not files.is_empty():
				# 创建按钮并添加到 UI
				video_item.cover_picture_path = video_item.preview_path + "/" + files[randi_range(0, files.size() -1)]
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
		video_item_scene.right_click.connect(_on_video_right_click)
		video_item_scene.cover_picture.custom_minimum_size = Vector2(252 + h_slider.value * 16, 141.75 + h_slider.value * 9)
		video_item_scene.custom_minimum_size = Vector2(256 + h_slider.value * 16, 280 + h_slider.value * 9)
		return video_item_scene

# 删除视频信息
func delete_video_info(id: int) -> bool:
	var video_item := VideoItemService.select_by_id(id)
	if not video_item:
		return false
	if video_item.cover_picture_path:
		FileUtil.del_file(video_item.cover_picture_path)
	return VideoItemService.logic_delete_by_id(video_item_tab.id)

# 视频项右键时
func _on_video_right_click(id: int) -> void:
	video_item_tab.position = DisplayServer.mouse_get_position()
	video_item_tab.visible = true
	video_item_tab.id = id

# 按下添加视频按钮时
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

func _on_import_video_button_pressed() -> void:
	DisplayServer.file_dialog_show(
	"选择视频目录", "", "", false,
	DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_DIR,
	[],
	func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		if selected_paths.is_empty():
			return
		var dir_path = selected_paths[0]
		# 添加任务，由任务执行
		TaskService.add_task(TaskService.Task_Type.VIDEO_IMPORT, {
			dir_path = dir_path,
		})
	)
# 视频容器滑动时
func _on_v_scroll_bar_value_changed(value: float) -> void:
	var v_scroll_bar := scroll_container.get_v_scroll_bar()
	var current_value = value + v_scroll_bar.page
	var nodes := [] # 节点数组
	var datas := [] # 节点对应的数据数组
	for panel: VideoItemContainer in h_flow.get_children():
		# 检查PanelContainer是否在视口范围内
		if not panel.is_loading_icon and panel.position.y < current_value:
			panel.is_loading_icon = true
			if panel.video_item.cover_picture_path:
				nodes.append(panel)
				datas.append({ "cover_picture_path" = panel.video_item.cover_picture_path})
	if not nodes.is_empty():
		TaskService.add_task(#DYNAMIC_LOAD_TEXTURE
			TaskService.Task_Type.DYNAMIC_LOAD_TEXTURE,
			{
				"nodes" = nodes,
				"datas" = datas,
				"texture_field" = "cover_picture_path",
				"texture_property" = "cover_picture_texture",
			}
		)

# 当视频项目变化时
func _on_change_video_item_array(type: VideoItemService.Change_Array_Type, video_item: VideoItem) -> void:
	match type:
		VideoItemService.Change_Array_Type.QUERY:
			refresh_video_item_all()
		VideoItemService.Change_Array_Type.SAVE:
			var arr = number_label.text.split("/")
			var video_item_container := instantiate_video_item(video_item)
			video_item_container.refresh_video_item(video_item)
			number_label.text = str(int(arr[0]) + 1) + "/" + str(int(arr[1]) + 1)
			h_flow.move_child(h_flow.get_child(h_flow.get_child_count() - 1), 0)
			
		VideoItemService.Change_Array_Type.UPDATE:
			for node: VideoItemContainer in h_flow.get_children():
				if node.video_item.id == video_item.id:
					video_item = VideoItemService.select_one(QueryBuilder.new().eq("id", video_item.id))
					if video_item:
						node.refresh_video_item(video_item)
						
		VideoItemService.Change_Array_Type.DELETE:
			for node: VideoItemContainer in h_flow.get_children():
				if node.video_item.id == video_item.id:
					node.queue_free()
					var arr = number_label.text.split("/")
					number_label.text = str(int(arr[0]) - 1) + "/" + str(int(arr[1]) - 1)

# 按下播放视频按钮时
func _on_play_button_pressed():
	video_item_tab.visible = false
	var video_item := VideoItemService.select_by_id(video_item_tab.id)
	var video_path = video_item.video_path
	SystemSettings.play_video(video_path)

# 按下打开影片按钮时
func _on_open_video_button_pressed():
	# 构建命令
	var video_item := VideoItemService.select_by_id(video_item_tab.id)
	var video_path = video_item.video_path
	OS.shell_show_in_file_manager(video_path)

# 按下打开海报图按钮时
func _on_open_poster_button_pressed():
	# 构建命令
	var video_item := VideoItemService.select_by_id(video_item_tab.id)
	var cover_picture_path = video_item.cover_picture_path
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(cover_picture_path))

# 按下打开预览图按钮时
func _on_open_preview_button_pressed():
	# 构建命令
	var video_item := VideoItemService.select_by_id(video_item_tab.id)
	var preview_path = video_item.preview_path
	if preview_path:
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path(preview_path))

# 按下更换封面时
func _on_replace_cover_button_pressed():
	video_item_tab.visible = false
	DisplayServer.file_dialog_show(
	"选择图片", "", "", false,
	DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
	FileUtil.get_file_type_filter(FileUtil.image_type),
	func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		print(_status)
		if selected_paths.is_empty():
			return
		# 检测视频
		var path := selected_paths[0]
		var video_item := VideoItemService.select_by_id(video_item_tab.id)
		var copy_path := FileUtil.copy_file(path, VideoItemService.COVER_PICTURE_PATH)
		if copy_path:
			FileUtil.del_file(video_item.cover_picture_path)
			VideoItemService.update(
				UpdateBuilder.new()
					.set_column("cover_picture_path", copy_path)
					.eq("id", video_item_tab.id)
			)
	)

# 按下生成截图时
func _on_generate_screenshot_button_pressed():
	video_item_tab.visible = false
	var video_item := VideoItemService.select_by_id(video_item_tab.id)
	# 任务类型

	TaskService.add_task(TaskService.Task_Type.REFRESH_PREVIEW,
		{
			"id" = video_item.id,
			"video_path" = video_item.video_path,
		}
	)
	pass

# 删除视频
func _on_delete_button_pressed() -> void:
	video_item_tab.visible = false
	delete_video_info(video_item_tab.id)

# 视频搜索
func _on_search_line_edit_text_submitted(new_text: String) -> void:
	refresh_video_item_all(new_text)

# 当所选视频库发生变化时
func _on_change_current_video_gallery() -> void:
	if visible:
		refresh_video_item_all()
	else:
		next_show_refresh = true
 
# 当前面板显示时
func _on_visibility_changed() -> void:
	if visible and next_show_refresh:
		next_show_refresh = false
		refresh_video_item_all()
