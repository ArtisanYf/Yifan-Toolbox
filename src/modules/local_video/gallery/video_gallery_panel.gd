extends VBoxContainer

const VIDEO_GALLERY_FUNCTION_WINDOW = preload("res://src/modules/local_video/gallery/video_gallery_function_window.tscn")
const VIDEO_GALLERY_ITEM = preload("res://src/modules/local_video/gallery/video_gallery_item.tscn")
const CONFIRMATION_DIALOG_BOX = preload("res://src/components/confirmation_dialog_box.tscn")

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var v: VBoxContainer = $ScrollContainer/V
@onready var create_button: Button = $SearchMargin/H/CreateButton
@onready var search_line_edit: LineEdit = $SearchMargin/H/SearchLineEdit
@onready var video_gallery_tab: VideoGalleryTab = $VideoGalleryTab
@onready var number_label: Label = $FunctionMargin/H/NumberLabel
@onready var search_button: Button = $SearchMargin/H/SearchLineEdit/SearchButton


func _ready():
	VideoGalleryService.change_video_gallery_array.connect(_on_change_video_gallery_array)
	scroll_container.get_v_scroll_bar().value_changed.connect(_on_v_scroll_bar_value_changed)
	create_button.pressed.connect(_on_create_button_pressed)
	search_button.pressed.connect(func(): refresh_video_gallery_all())
	search_line_edit.text_submitted.connect(_on_search_line_edit_text_submitted)
	video_gallery_tab.set_picture.connect(_on_gallery_set_picture)
	video_gallery_tab.rename.connect(_on_gallery_rename)
	video_gallery_tab.delete.connect(_on_gallery_delete)
	
	refresh_video_gallery_all()
	
# 更新视频库容器
func refresh_video_gallery_all(search_name: String = search_line_edit.text) -> void:
	# 删除所有子节点
	for node in v.get_children():
		node.queue_free()
	
	var video_gallery_array := VideoGalleryService.select_array(
		QueryBuilder.new()
		.select(["*"])
		.like("video_gallery_name", search_name, search_name != "")
		.orderByDesc("create_time")
	)
	var count: int = 0
	for video_gallery: VideoGallery in video_gallery_array:
		count = instantiate_video_gallery(count, video_gallery)
	number_label.text = str(count) + "/" + str(video_gallery_array.size())
	await get_tree().process_frame
	_on_v_scroll_bar_value_changed(0)

			
# 实例化场景	
func instantiate_video_gallery(count: int, video_gallery: VideoGallery) -> int:
		var video_gallery_item = VIDEO_GALLERY_ITEM.instantiate()
		# 将实例化的场景添加到父节点
		v.add_child(video_gallery_item)
		# 初始化传参
		video_gallery_item.init_video_gallery(video_gallery)
		video_gallery_item.right_click.connect(_on_gallery_right_click)
		count += 1
		return count

# 删除视频库
func delete_video_gallery(id: int) -> bool:
	var video_gallery = VideoGalleryService.select_one(QueryBuilder.new().eq("id", id))
	if not video_gallery:
		return false
	if VideoGalleryService.logic_delete(
		UpdateBuilder.new()
			.set_column("cover_picture_path", "")
			.eq("id", id)
	):
		# todo
		FileUtil.del_file(video_gallery.cover_picture_path)
		return true
	return false

func _on_gallery_right_click(id: int) -> void:
	video_gallery_tab.position = DisplayServer.mouse_get_position()
	video_gallery_tab.visible = true
	video_gallery_tab.id = id

func _on_gallery_set_picture(id: int) -> void:
		DisplayServer.file_dialog_show(
			"选择图片", "", "", false,
			DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
			["*.jpg", "*.png"],
			func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
				if selected_paths.is_empty():
					return
				var destination_path := FileUtil.copy_file(selected_paths[0], VideoGalleryService.COVER_PICTURE_PATH)
				if destination_path == "":
					return
				var update_builder := UpdateBuilder.new()
				update_builder.eq("id", id)
				update_builder.set_column("cover_picture_path", destination_path)
				VideoGalleryService.update(update_builder)
		)

func _on_gallery_rename(id: int) -> void:
	var video_gallery_function_window := VIDEO_GALLERY_FUNCTION_WINDOW.instantiate()
	get_tree().current_scene.add_child(video_gallery_function_window)
	video_gallery_function_window.init_window({
		"title_window" = "重命名",
		"window_type" = video_gallery_function_window.Window_Type.RENAME,
		"video_gallery_id" = id
	})

func _on_gallery_delete(id: int) -> void:
	var confirmation_dialog_box := CONFIRMATION_DIALOG_BOX.instantiate()
	get_tree().current_scene.add_child(confirmation_dialog_box)
	confirmation_dialog_box.init_scene({"title" = "提示","content" = "确认删除？", "id" = id})
	confirmation_dialog_box.confirm.connect(func(params: Dictionary): delete_video_gallery(params.id))
	
	
func _on_v_scroll_bar_value_changed(value: float) -> void:
	var v_scroll_bar := scroll_container.get_v_scroll_bar()
	var current_value = value + v_scroll_bar.page
	var nodes := [] # 节点数组
	var datas := [] # 节点对应的数据数组
	for panel in v.get_children():
		# 检查PanelContainer是否在视口范围内
		if not panel.is_loading_icon and panel.position.y < current_value:
			panel.is_loading_icon = true
			if panel.video_gallery.cover_picture_path != "":
				nodes.append(panel)
				datas.append({ "cover_picture_path" = panel.video_gallery.cover_picture_path})
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

func _on_create_button_pressed() -> void:
	var video_gallery_function_window := VIDEO_GALLERY_FUNCTION_WINDOW.instantiate()
	get_tree().current_scene.add_child(video_gallery_function_window)
	
func _on_change_video_gallery_array(type: VideoGalleryService.Change_Array_Type, video_gallery: VideoGallery) -> void:
	match type:
		VideoGalleryService.Change_Array_Type.SAVE:
			var arr = number_label.text.split("/")
			instantiate_video_gallery(int(arr[0]), video_gallery)
			number_label.text = str(int(arr[0]) + 1) + "/" + str(int(arr[1]) + 1)
			v.move_child(v.get_child(v.get_child_count() - 1), 0)
		VideoGalleryService.Change_Array_Type.UPDATE:
			for node: VideoGalleryItem in v.get_children():
				if node.video_gallery.id == video_gallery.id:
					video_gallery = VideoGalleryService.select_one(QueryBuilder.new().eq("id", video_gallery.id))
					if video_gallery:
						node.refresh_video_gallery(video_gallery)
		VideoGalleryService.Change_Array_Type.DELETE:
			for node: VideoGalleryItem in v.get_children():
				if node.video_gallery.id == video_gallery.id:
					node.queue_free()
					var arr = number_label.text.split("/")
					number_label.text = str(int(arr[0]) - 1) + "/" + str(int(arr[1]) - 1)


func _on_search_line_edit_text_submitted(new_text: String) -> void:
	refresh_video_gallery_all(new_text)
