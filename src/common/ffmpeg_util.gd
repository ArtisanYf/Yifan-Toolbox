class_name FFmpegUtil
extends Node


## 
const FFMPEG_PATH := "D:/download/chrome/ffmpeg-7.0.2-full_build/bin/ffmpeg.exe"
const FFPROBE_PATH := "D:/download/chrome/ffmpeg-7.0.2-full_build/bin/ffprobe.exe"


# 捕获视频截图
static func capture_video_screenshot(ffmpeg_path: String, cut_time: String, video_path: String, save_path: String) -> bool:
	# 检查文件是否存在，如果存在则删除
	FileUtil.del_file(save_path)
	#"-hwaccel", "cuda",
	var args = [
		"-ss", cut_time, # 截取时间  cut_time 格式：hh:mm:ss
		"-i", video_path, # 指定视频路径
		"-vframes", "1", # 截取一帧
		"-q:v", "2", # 截取图像的质量 1 ~ 31 越高质量越低
		save_path, # 截取图像保存路径
	]
	var output = []
	var exit_code = OS.execute(ffmpeg_path, args, output, false, false)
	if exit_code != 0:
		print("捕获视频截图失败，错误id = " + str(exit_code))
		return false
	return true
	
# 捕获视频信息
static func get_video_info(ffprobe_path: String, video_file: String) -> Dictionary:
	if not ffprobe_path:
		return {}

	var command = [
		"ffprobe", 
		"-v", "error", 
		"-show_entries", "format=duration,size,format_name,bit_rate",
		"-show_entries", "stream=codec_name,width,height,bit_rate,avg_frame_rate,pix_fmt,bits_per_raw_sample,nb_frames,sample_rate,channels",
		"-of", "json", 
		video_file
		]
	
	var output := []
	var exit_code = OS.execute(ffprobe_path, command.slice(1), output, false, false)
	# 使用 OS.execute 执行命令
	if exit_code != OK:
		print("Failed to execute ffprobe. Exit code: ", exit_code)
		return {}
	if output.is_empty():
		return {}
	var json = JSON.new()
	json.parse(output[0])
	var arror = json.get_error_line()
	if arror == 0:
		return json.data
	return {}

# 获取视频中的第一帧作为图片保存
static func get_video_first_frame(ffmpeg_path: String, video_path: String, storage_path: String) -> String:
	var cover_name := str(DateUtil.unix_current_time()) + str(RandomNumberGenerator.new().randi_range(100000,999999))
	var output_image_path = ProjectSettings.globalize_path(storage_path) + cover_name + ".jpg"  # 指定输出文件路径
	var args = [
		"-i", video_path,
		"-an",
		"-vframes", "1",
		#"-s", "1280x720",
		"-q:v", "2",
		output_image_path
	]
	var output := []
	var exit_code = OS.execute(ffmpeg_path, args, output, false, false)
	if exit_code == 0:
		return storage_path + cover_name + ".jpg"
	else:
		print("Failed to execute ffprobe. Exit code: ", exit_code)
		return ""
