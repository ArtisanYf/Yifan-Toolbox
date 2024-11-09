class_name VideoGallery
extends RefCounted

# 主键
var id: int

# 名称
var video_gallery_name: String

# 封面
var cover_picture_path: String

# 创建时间
var create_time: String

# 是否删除
var is_deleted: bool

# 构造函数，接收字典作为参数
func _init(data: Dictionary = {}):
	# 使用 get 方法提供默认值，避免未定义键报错
	id = data.get("id", 0)
	video_gallery_name = data.get("video_gallery_name", "")
	cover_picture_path = data.get("cover_picture_path", "")
	create_time = data.get("create_time", "")
	is_deleted = data.get("is_deleted", false)

# from_dict 方法，用于将字典转换为对象
func from_dict(data: Dictionary) -> VideoGallery:
	id = data.get("id", 0)
	video_gallery_name = data.get("video_gallery_name", "")
	cover_picture_path = data.get("cover_picture_path", "")
	create_time = data.get("create_time", "")
	is_deleted = data.get("is_deleted", false)
	return self
	
# 将对象转换为字典
func to_dict() -> Dictionary:
	var dict = {}
	if id != 0:
		dict["id"] = id
	dict["video_gallery_name"] = video_gallery_name
	dict["cover_picture_path"] = cover_picture_path
	dict["create_time"] = create_time
	dict["is_deleted"] = is_deleted
	return dict
