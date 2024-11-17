class_name FileUtil
extends Node

static var video_type = ["mp4", "avi"]

static var image_type = ["png", "jpg"]


# 查询文件
static func query_file(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return []
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Array
	file.close()
	return data

# 保存文件
static func save_file(data: Array, path: String) -> bool:
	var json := JSON.stringify(data)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(json)
	file.close()
	return true

# 复制文件
static func copy_file(source_path: String, store_dir: String) -> String:
	# 使用 FileAccess 复制文件
	var source_file := FileAccess.open(source_path, FileAccess.ModeFlags.READ)
	#指定目标路径，确保使用相同的扩展名
	var destination_path = store_dir + str(DateUtil.unix_current_time()) + str(RandomNumberGenerator.new().randi_range(100000,999999)) + "." + source_path.get_file().get_extension()
	if source_file:
		var destination_file = FileAccess.open(destination_path, FileAccess.ModeFlags.WRITE)
		if destination_file:
			destination_file.store_buffer(source_file.get_buffer(source_file.get_length()))
			destination_file.close()
			return destination_path
		else:
			source_file.close()
			return ""
	else:
		return ""
		
# 删除文件
static func del_file(file_path: String) -> void:
	# 检查文件是否存在，如果存在则删除
	if FileAccess.file_exists(file_path):
		#var file_access = FileAccess.open(file_path, FileAccess.READ)  # 打开文件
		#file_access.close()  # 关闭文件
		DirAccess.remove_absolute(file_path)  # 删除文件

# 删除目录 如果目录下有目录则删除目录失败，但会删除本目录下所有文件
static func del_dir(dir_path: String) -> void:
	var files := DirAccess.get_files_at(dir_path)
	for file in files:
		var file_path := dir_path + "/" +file
		DirAccess.remove_absolute(file_path)  # 删除文件
	DirAccess.remove_absolute(dir_path) 


# 将文件扩展名转换为 FileDialog 所需的过滤格式
static func get_file_type_filter(file_types: Array) -> PackedStringArray:
	var filter_string = "*.{0}".format([file_types[0]])
	for i in range(1, file_types.size()):
		filter_string += ",*.{0}".format([file_types[i]])
	
	return PackedStringArray([filter_string])
