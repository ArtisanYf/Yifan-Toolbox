extends Node

# 系统设置存放文件地址
const SYSTEM_SETTINGS_PATH := "user://system_settings.sav"

# 系统设置信息
var system_settings_data := {
	video_handle = {
		ffmpeg = {
			ffmpeg_path = "",
			ffprobe_path = "",
		},
		screenshot = {
			enable = false,
			amount = 10,
		}
	},
	viewport_size_select = [
		{
			viewport_width = 1920,
			viewport_height = 1080,
			is_select = false,
			video_item_size = {
				width = 345,
				height = 300,
			}
		},
		{
			viewport_width = 1920,
			viewport_height = 1080,
			is_select = true,
		},
	]
}

func _ready() -> void:
	# 初始化视频项列表
	var array := FileUtil.query_file(SYSTEM_SETTINGS_PATH)
	if array and not array.is_empty():
		system_settings_data = FileUtil.query_file(SYSTEM_SETTINGS_PATH)[0]
	var ffmpeg_path = get_ffmpeg_path()

	if ffmpeg_path == "":
		if OS.has_feature("editor"):
			system_settings_data.video_handle.ffmpeg.ffmpeg_path = ProjectSettings.globalize_path("res://ffmpeg/bin/ffmpeg.exe")
		else:
			system_settings_data.video_handle.ffmpeg.ffmpeg_path = OS.get_executable_path().get_base_dir() + "/ffmpeg/bin/ffmpeg.exe"
			
	var ffprobe_path = get_ffprobe_path()
	if ffprobe_path == "":
		if OS.has_feature("editor"):
			system_settings_data.video_handle.ffmpeg.ffprobe_path = ProjectSettings.globalize_path("res://ffmpeg/bin/ffprobe.exe")
		else:
			system_settings_data.video_handle.ffmpeg.ffprobe_path = OS.get_executable_path().get_base_dir() + "/ffmpeg/bin/ffprobe.exe"

func get_ffmpeg_path() -> String:
	return system_settings_data.video_handle.ffmpeg.ffmpeg_path
	
func get_ffprobe_path() -> String:
	return system_settings_data.video_handle.ffmpeg.ffprobe_path

func save_settings() -> bool:
	return FileUtil.save_file([system_settings_data], SYSTEM_SETTINGS_PATH)

func get_viewport_size() -> Vector2:
	for viewport_size in system_settings_data["viewport_size_select"]:
		if viewport_size.is_select:
			return Vector2(viewport_size.viewport_width, viewport_size.viewport_height)
	return Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))  
