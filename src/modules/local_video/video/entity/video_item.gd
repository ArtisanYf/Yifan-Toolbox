class_name VideoItem
extends BaseEntity

signal change_video_name

signal change_video_path

signal change_cover_picture_path

signal change_create_time

# 主键
var id: int

# 视频库id
var video_gallery_id: int

# 视频名称
var video_name: String:
	set(v):
		video_name = v
		change_video_name.emit()

# 视频路径
var video_path: String:
	set(v):
		video_path = v
		change_video_path.emit()

# 封面图片
var cover_picture_path: String:
	set(v):
		cover_picture_path = v
		change_cover_picture_path.emit()

# 添加时间
var create_time: String:
	set(v):
		create_time = v
		change_create_time.emit()

# 预览图目录
var preview_path: String

# 标签
var labels: Array

# 其他图片路径目录
var other_picture_paths: Array

# 发布时间
var publish_time: String

# 大纲
var outline: String

var is_deleted: bool

## 构造函数，接收字典作为参数
#func _init(data: Dictionary = {}):
	## 使用 get 方法提供默认值，避免未定义键报错
	#id = data.get("id", 0)
	#video_gallery_id = data.get("video_gallery_id", 0)
	#video_name = data.get("video_name", "")
	#video_path = data.get("video_path", "")
	#cover_picture_path = data.get("cover_picture_path", "")
	#create_time = data.get("create_time", "")
	#preview_path = data.get("preview_path", "")
	#if "labels" in data and data["labels"]:
		#labels = JSON.parse_string(data["labels"])
	#outline = data.get("outline", "")
	#if "other_picture_paths" in data and data["other_picture_paths"]:
		#other_picture_paths = JSON.parse_string(data["other_picture_paths"])
	#publish_time = data.get("publish_time", "")
	#is_deleted = data.get("is_deleted", false)


## 将对象转换为字典
#func to_dict() -> Dictionary:
	#var dict = {}
	#if id != 0:
		#dict["id"] = id
	#dict["video_gallery_id"] = video_gallery_id
	#dict["video_name"] = video_name
	#dict["video_path"] = video_path
	#dict["cover_picture_path"] = cover_picture_path
	#dict["create_time"] = create_time
	#dict["preview_path"] = preview_path
	#dict["labels"] = str(labels)
	#dict["outline"] = outline
	#dict["other_picture_paths"] = str(other_picture_paths)
	#dict["publish_time"] = publish_time
	#dict["is_deleted"] = is_deleted
	#return dict

## 初始化
#func init_entity(data: Dictionary):
	#id = data.id
	#video_gallery_id = data.video_gallery_id
	#if "video_name" in data and data["video_name"]:
		#video_name = data.video_name
	#if "video_path" in data and data["video_path"]:
		#video_path = data.video_path
	#if "cover_picture_path" in data and data["cover_picture_path"]:
		#cover_picture_path = data.cover_picture_path
	#if "create_time" in data and data["create_time"]:
		#create_time = data.create_time
	#if "preview_path" in data and data["preview_path"]:
		#preview_path = data.preview_path
	#if "labels" in data and data["labels"]:
		#labels = JSON.parse_string(data["labels"])
	#if "outline" in data and data["outline"]:
		#outline = data.outline
	#if "other_picture_paths" in data and data["other_picture_paths"]:
		#other_picture_paths = JSON.parse_string(data["other_picture_paths"])
	#if "publish_time" in data and data["publish_time"]:
		#publish_time =  data["publish_time"]
