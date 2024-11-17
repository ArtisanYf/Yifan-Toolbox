extends Window


var video_setting: VideoSetting = SystemSettings.video_setting

@onready var save_button: Button = $Panel/V/OperateMargin/H/SaveButton
@onready var play_line_edit: LineEdit = $Panel/V/Margin/BaseHBox/PlayHBoxc/PlayLineEdit
@onready var play_select_button: Button = $Panel/V/Margin/BaseHBox/PlayHBoxc/PlaySelectButton
@onready var ffmpeg_line_edit: LineEdit = $Panel/V/Margin/VideoHandleHBox/BaseHBox/Panel/V/FFmpegHBox/FFmpegLineEdit
@onready var ffprobe_line_edit: LineEdit = $Panel/V/Margin/VideoHandleHBox/BaseHBox/Panel/V/FFprobeHBox/FFprobeLineEdit
@onready var ffmpeg_select_button: Button = $Panel/V/Margin/VideoHandleHBox/BaseHBox/Panel/V/FFmpegHBox/FFmpegSelectButton
@onready var ffprobe_select_button: Button = $Panel/V/Margin/VideoHandleHBox/BaseHBox/Panel/V/FFprobeHBox/FFprobeSelectButton
@onready var tips_container: TipsContainer = $CanvasLayer/TipsContainer
@onready var tab_bar: TabBar = $Panel/V/TabBar
@onready var base_h_box: VBoxContainer = $Panel/V/Margin/BaseHBox
@onready var video_handle_h_box: HBoxContainer = $Panel/V/Margin/VideoHandleHBox

func _ready() -> void:
	save_button.pressed.connect(_on_save_button_pressed)
	play_select_button.pressed.connect(func(): _on_select_button_pressed(play_line_edit))
	ffmpeg_select_button.pressed.connect(func(): _on_select_button_pressed(ffmpeg_line_edit))
	ffprobe_select_button.pressed.connect(func(): _on_select_button_pressed(ffprobe_line_edit))
	
	video_setting = SystemSettings.video_setting
	play_line_edit.text = video_setting.play_path
	ffmpeg_line_edit.text = video_setting.ffmpeg_path
	ffprobe_line_edit.text = video_setting.ffprobe_path
	tab_bar.tab_selected.connect(func(tab: int):
		base_h_box.visible = false
		video_handle_h_box.visible = false
		if tab_bar.get_tab_title(tab) == "基本":
			base_h_box.visible = true
		elif tab_bar.get_tab_title(tab) == "视频处理":
			video_handle_h_box.visible = true
	)
	
func _on_save_button_pressed() -> void:
	video_setting.play_path = play_line_edit.text
	video_setting.ffmpeg_path = ffmpeg_line_edit.text
	video_setting.ffprobe_path = ffprobe_line_edit.text
	SystemSettings.save_video_settings()
	tips_container.animation_player.play("success_tips")


func _on_select_button_pressed(line_edit: LineEdit) -> void:
	DisplayServer.file_dialog_show(
	"选择", "", "", false,
	DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
	["*.exe"],
	func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		if selected_paths.is_empty():
			return
		var path := selected_paths[0]
		line_edit.text = path
	)

#func _on_play_select_button_pressed() -> void:
	#DisplayServer.file_dialog_show(
	#"选择", "", "", false,
	#DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
	#["*.exe"],
	#func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		#if selected_paths.is_empty():
			#return
		## 检测视频
		#var path := selected_paths[0]
		#play_line_edit.text = path
	#)
	#
#func _on_ffmpeg_select_button_pressed() -> void:
	#DisplayServer.file_dialog_show(
	#"选择", "", "", false,
	#DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
	#["*.exe"],
	#func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		#if selected_paths.is_empty():
			#return
		## 检测视频
		#var path := selected_paths[0]
		#ffmpeg_select_button.text = path
	#)
#
#func _on_ffprobe_select_button_pressed() -> void:
	#DisplayServer.file_dialog_show(
	#"选择", "", "", false,
	#DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE,
	#["*.exe"],
	#func(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
		#if selected_paths.is_empty():
			#return
		## 检测视频
		#var path := selected_paths[0]
		#ffprobe_line_edit.text = path
	#)
