extends Node

# 当前所选视频库发生变化发出
signal change_current_video_gallery

# 当视频库列表发生变化时发出
signal change_video_gallery_array(type: Change_Array_Type, video_gallery: VideoGallery)

# 视频库列表变更信号类型
enum Change_Array_Type{
	QUERY,
	SAVE,
	UPDATE,
	DELETE,
}

# 视频库图片目录
const COVER_PICTURE_PATH := "user://video_gallery_cover_picture/"

# 表名
const TABLE_NAME := "t_video_gallery"

# 字段名
var columns = ["id", "video_gallery_name", "cover_picture_path", "create_time", "is_deleted"]

# db
var db := DB.db
#
# 当前所选视频库
var current_video_gallery: VideoGallery:
	set(v):
		current_video_gallery = v
		change_current_video_gallery.emit()

func _init() -> void:
	var table_dict :=VideoGallery.new().table_dict()
	# 通过 sql 检查表是否已存在
	db.query_with_bindings("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", [TABLE_NAME])
	if db.query_result.is_empty():
		# 创建表
		db.create_table(TABLE_NAME, table_dict)

func _ready() -> void:
	print("视频库初始化...")
	# 静态创建目录
	DirAccess.make_dir_absolute(COVER_PICTURE_PATH)
	
## 查询列
func select_array(query_buildder: QueryBuilder) -> Array:
	var array := db.select_rows(TABLE_NAME, query_buildder.conditions, query_buildder.columns)
	var gallery_array = []
	for dict in array:
		gallery_array.append(VideoGallery.new(dict))
	return gallery_array

## 查询列
func select_one(query_buildder: QueryBuilder) -> VideoGallery:
	var array := db.select_rows(TABLE_NAME, query_buildder.conditions, query_buildder.columns)
	if array.is_empty():
		return null
	return VideoGallery.new(array[0])
	
## 新增库
func insert(video_gallery: VideoGallery) -> bool:
	var success = db.insert_row(TABLE_NAME, video_gallery.to_dict())
	if success:
		# 本次新增的 id
		video_gallery.id = db.last_insert_rowid
		change_video_gallery_array.emit(Change_Array_Type.SAVE, video_gallery)
	return success

## 更新库
func update(update_builder: UpdateBuilder) -> bool:
	var success = db.update_rows(TABLE_NAME, update_builder.conditions, update_builder.dict)
	if success:
		change_video_gallery_array.emit(Change_Array_Type.UPDATE, VideoGallery.new(update_builder.param))
	return success

# 删除库
func delete(basic_builder: BasicBuilder) -> bool:
	var success = db.delete_rows(TABLE_NAME, basic_builder.conditions)
	if success:
		change_video_gallery_array.emit(Change_Array_Type.DELETE, null)
	return success

# 逻辑删除
func logic_delete(update_builder: UpdateBuilder) -> bool:
	if update_builder.table_logic:
		update_builder.dict[update_builder.table_logic] = 1
	var success = db.update_rows(TABLE_NAME, update_builder.conditions, update_builder.dict)
	if success:
		var video_gallery = VideoGallery.new()
		video_gallery.id = update_builder.param.id
		change_video_gallery_array.emit(Change_Array_Type.DELETE, video_gallery)
	return success
