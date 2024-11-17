class_name VideoGallery
extends BaseEntity

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

## 构造函数，接收字典作为参数
#func _init(data: Dictionary = {}):
	## 使用 get 方法提供默认值，避免未定义键报错
	#id = data.get("id", 0)
	#video_gallery_name = data.get("video_gallery_name", "")
	#cover_picture_path = data.get("cover_picture_path", "")
	#create_time = data.get("create_time", "")
	#is_deleted = data.get("is_deleted", false)
