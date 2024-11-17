extends Node

## 任务

# 进度
signal progress_signal(value, task_name)

#signal task_queue_size(size)

# 任务类型
enum Task_Type{
	LOAD_TEXTURE, # 加载纹理
	LOAD_TEXTURE_2, # 加载纹理
	DYNAMIC_LOAD_TEXTURE, # 动态纹理加载
	REFRESH_PREVIEW, # 刷新预览图片
	VIDEO_IMPORT, # 视频导入
}

# 纹理加载
var load_texture_data := {
	"thread" = Thread.new(), # 当前加载的线程
	"is_start" = false, # 是否启动
	"is_stop" = false, # 是否中止
}

# 动态纹理加载
var dynamic_load_texture_data := {
	"thread" = Thread.new(), # 当前加载的线程
	"is_start" = false, # 是否启动
	"is_stop" = false, # 是否中止
	"nodes" = [],
	"datas" = [],
}
## 纹理加载
#var load_texture_data_2 := {
	#"thread" = Thread.new(), # 当前加载的线程
	#"is_start" = false, # 是否启动
	#"is_stop" = false,	# 是否中止
#}

# 用户任务线程池
var thread_array: Array

#最大线程数量
var max_thread: int = 1

# 任务队列
var task_queue := []

# 本次运行任务执行的队列
var task_info_array: Array

var progress: float




func _ready() -> void:
	print("任务服务加载完成...")

# 添加任务
func add_task(type: Task_Type, params: Dictionary) -> bool:
	var task_id = DateUtil.unix_current_time()
	task_info_array.append({
		task_id = task_id,
		type = type,
	})
	params["task_id"] = task_id
	match type:
		Task_Type.LOAD_TEXTURE:
			load_texture(params.get("nodes"), params.get("datas"), params.get("texture_field"), params.get("texture_property"), load_texture_data)
			return true
		#Task_Type.LOAD_TEXTURE_2:
			#load_texture(params.get("nodes"), params.get("data"), params.get("texture_field"), params.get("texture_property"), load_texture_data_2)
			#return true
		Task_Type.DYNAMIC_LOAD_TEXTURE:
			dynamic_load_texture(params.get("nodes"), params.get("datas"), params.get("texture_field"), params.get("texture_property"))
		Task_Type.REFRESH_PREVIEW, Task_Type.VIDEO_IMPORT:
			assign_task(type, params)
	return true
	


#DYNAMIC_LOAD_TEXTURE
func dynamic_load_texture(nodes: Array, datas: Array, texture_field: String, texture_property: String) -> void:
	dynamic_load_texture_data.nodes.append_array(nodes)
	dynamic_load_texture_data.datas.append_array(datas)
	if dynamic_load_texture_data.is_start:
		return
	dynamic_load_texture_data.is_start = true
	var loading_mutex = Mutex.new()
	dynamic_load_texture_data.thread = Thread.new()
	dynamic_load_texture_data.thread.start(func():
		while dynamic_load_texture_data.datas.size() > 0:
			var data = dynamic_load_texture_data.datas.pop_front()  # 从数组头部取出元素
			var node = dynamic_load_texture_data.nodes.pop_front()
			if not is_instance_valid(node):
				continue
			var texture = TextureUtil.create_texture(data.get(texture_field))
			# 使用 Mutex 锁保护 UI 更新
			if dynamic_load_texture_data.is_stop:
				print("加载任务已停止.")
				return
			loading_mutex.lock()
			call_deferred("update_texture", node, texture, texture_property)  # 更新按钮图标
			loading_mutex.unlock()
		dynamic_load_texture_data.is_start = false  # 标记加载完成
		print("加载纹理任务执行完毕!")
		call_deferred("wait_to_finsh", dynamic_load_texture_data.thread)
	)
	pass
	

# 加载纹理到指定的节点数组中
# @param nodes: 包含目标节点的数组，每个节点都需要更新纹理。
# @param data: 包含纹理路径或资源信息的数组，与 nodes 对应。
# @param texture_field: 用于从 data 中获取纹理路径的字段名。
# @param texture_property: 要在节点上更新的纹理属性名称（如 "cover_picture_texture"）。
func load_texture(nodes: Array, datas: Array, texture_field: String, texture_property: String, _load_texture_data: Dictionary) -> void:
	# 如果已有加载操作，先中止
	if _load_texture_data.is_start:
		_load_texture_data.is_stop = true  # 设置停止标志
		print("正在中止上一个加载任务...")
		 # 等待当前线程结束
		_load_texture_data.thread.wait_to_finish()
	# 重置状态
	_load_texture_data.is_start = true
	_load_texture_data.is_stop = false  # 确保加载前重置停止标志
	var loading_mutex = Mutex.new()
	_load_texture_data.thread = Thread.new()
	# 线程启动
	_load_texture_data.thread.start(func():
		for i in range(0, datas.size()):
			var node = nodes[i]
			var data = datas[i]
			if not is_instance_valid(node):
				continue
			var texture = TextureUtil.create_texture(data.get(texture_field))
			# 使用 Mutex 锁保护 UI 更新
			if _load_texture_data.is_stop:
				print("加载任务已停止.")
				return
			loading_mutex.lock()
			call_deferred("update_progress", float(i + 1) / nodes.size(), "11")
			call_deferred("update_texture", node, texture, texture_property)  # 更新按钮图标
			loading_mutex.unlock()
		nodes.clear()
		_load_texture_data.is_start = false  # 标记加载完成
		print("加载纹理任务执行完毕!")
		call_deferred("wait_to_finsh", _load_texture_data.thread)
	)

func wait_to_finsh(thread: Thread) -> void:
	if not thread.is_alive():
		thread.wait_to_finish()

# 在主线程中更新图标
func update_texture(node: Node, texture: Texture, texture_property: String) -> void:
	node.set(texture_property, texture) #设置图标

# 分配任务
func assign_task(type: Task_Type, params: Dictionary):
	if thread_array.size() == max_thread:
		add_task_queue(type, params)
		return
		
	var thread = Thread.new()
	thread_array.append(thread)
	thread.start(execute.bind(type, params, thread))

# 添加队列
func add_task_queue(type: Task_Type, params: Dictionary) -> void:
	match type:
		Task_Type.REFRESH_PREVIEW:
			task_queue.append({
				type = Task_Type.REFRESH_PREVIEW,
				id = params.id,
				path = params.path,
				task_id = params.task_id,
			})
		Task_Type.VIDEO_IMPORT:
			task_queue.append({
				type = Task_Type.REFRESH_PREVIEW,
				dir_path = params.dir_path,
				task_id = params.task_id,
			})

# 执行
func execute(type: Task_Type, params: Dictionary, thread: Thread) -> void:
	match type:
		Task_Type.REFRESH_PREVIEW:
			refresh_preview_picture(type, params, thread)
		Task_Type.VIDEO_IMPORT:
			video_import(type, params, thread)

## 生成预览图	
func refresh_preview_picture(type: Task_Type, params: Dictionary, thread: Thread) -> void:
	var task_name = "生成预览图"
	var id: int = params.id
	var video_path: String = params.video_path
	
	var dict: Dictionary= FFmpegUtil.get_video_info(SystemSettings.video_setting.ffprobe_path, video_path)
	if not dict.is_empty():
		var loading_mutex = Mutex.new()
		
		# 视频时长 秒
		var video_duration := float(dict.format.get('duration', 'N/A'))
		
		# 间隔段数
		var intervals := DateUtil.get_hh_mm_ss_intervals(video_duration, 
			int(16)
		)
		
		# 存放目录
		var dir_path = ProjectSettings.globalize_path(VideoItemService.PREVIEW_VIDEO_PATH) + str(id) + "/"
		print(dir_path)
		DirAccess.make_dir_absolute(dir_path)
		
		for i in range(intervals.size()):
			FFmpegUtil.capture_video_screenshot(
				SystemSettings.video_setting.ffmpeg_path,
				intervals[i],
				video_path, 
				dir_path + "ScreenShot-" + str(i + 1).pad_zeros(3) + ".jpg"
			)
			loading_mutex.lock()
			call_deferred("update_progress", float(i + 1) / intervals.size(), task_name)
			loading_mutex.unlock()
		call_deferred("update_video_item_preview", id, dir_path)
		for task_info in task_info_array:
			if task_info.task_id == params.task_id:
				task_info["thread_id"] = thread.get_id()
				task_info["end_time"] = DateUtil.unix_current_time()
	print(task_info_array)
	if not task_queue.is_empty():
		var data: Dictionary = task_queue[0]
		task_queue.remove_at(0)
		execute(data.type, data, thread)
	thread_array.erase(thread)

func update_video_item_preview(id: int, path: String)-> void:
	VideoItemService.update(UpdateBuilder.new().set_column("preview_path", path).eq("id", id))

## 视频目录导入
func video_import(type: Task_Type, params: Dictionary, thread: Thread) -> void:
	var task_name = "导入视频"
	var loading_mutex = Mutex.new()
	var dir_path: String = params.dir_path
	var files := DirAccess.get_files_at(dir_path)
	var array: Array = []
	for i in range(files.size()):
		var extension = files[i].get_extension()
		if extension.to_lower() not in ["mp4", "avi", "mov","mkv","ts"]:
			print("视频导入过滤掉的类型：{}".format([extension]))
			loading_mutex.lock()
			call_deferred("update_progress", float(i + 1) / files.size(), task_name)
			loading_mutex.unlock()
			continue
		var source_path = dir_path + "\\" + files[i]
		var cover_picture_path = FFmpegUtil.get_video_first_frame(SystemSettings.get_ffmpeg_path(), source_path, VideoItemService.COVER_PICTURE_PATH)
		if cover_picture_path == "":
			loading_mutex.lock()
			call_deferred("update_progress", float(i + 1) / files.size(), task_name)
			loading_mutex.unlock()
			continue
		var video_item := VideoItem.new()
		video_item.video_gallery_id = VideoGalleryService.current_video_gallery.id
		video_item.video_name = source_path.get_basename().get_file()
		video_item.video_path = source_path
		video_item.create_time = DateUtil.format_current_time()
		video_item.cover_picture_path = cover_picture_path

		array.append(video_item)
		loading_mutex.lock()
		call_deferred("update_progress", float(i + 1) / files.size(), task_name)
		loading_mutex.unlock()
	call_deferred("insert_video_item", array)
	for task_info in task_info_array:
		if task_info.task_id == params.task_id:
			task_info["thread_id"] = thread.get_id()
			task_info["end_time"] = DateUtil.unix_current_time()
	print(task_info_array)
	if not task_queue.is_empty():
		var data: Dictionary = task_queue[0]
		task_queue.remove_at(0)
		execute(data.type, data, thread)
	thread_array.erase(thread)
	#
func insert_video_item(array: Array):
	VideoItemService.insert_batch(array)
	#

func update_progress(v: float, task_name: String):
	progress = v
	progress_signal.emit(progress, task_name)
	print("Progress: ", progress)
#
#
#
# 在 Godot 关闭时触发，清理线程
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if load_texture_data.thread != null:
			load_texture_data.thread.wait_to_finish()  # 确保线程完成任务后退出
	pass

## 停止线程
#func _exit_tree():
