extends Node

# 当前所选视频库发生变化发出
signal change_current_video_gallery

# 当视频库列表发生变化时发出
signal change_video_gallery_array

# 视频库图片目录
const COVER_PICTURE_PATH := "user://video_gallery_cover_picture/"

# 表名
const TABLE_NAME := "t_video_gallery"

## 视频库列表
#var video_gallery_array: Array

# 字段名
var columns = ["id", "video_gallery_name", "cover_picture_path", "create_time"]

# db
var db := DB.db

# 当前所选视频库
var current_video_gallery :Dictionary:
	set(v):
		current_video_gallery = v
		change_current_video_gallery.emit()

func _init() -> void:
	var table_dict: Dictionary = {
		"id": 
			{
				"data_type":"int", # 类型
				"primary_key": true, # 是否主键
				"not_null": true, # 不能为 null
				"auto_increment": true # 自增
			},
		"video_gallery_name": 
			{
				"data_type":"text",
				"not_null": true
			},
		"cover_picture_path":
			{
				"data_type":"text",
				"not_null": true
			},
		"create_time":
			{
				"data_type":"text",
				"not_null": true
			}		
	}
	# 通过 sql 检查表是否已存在
	db.query_with_bindings("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", [TABLE_NAME])
	if db.query_result.is_empty():
		# 创建表
		db.create_table(TABLE_NAME, table_dict)

func _ready() -> void:
	print("视频库初始化...")
	# 静态创建目录
	DirAccess.make_dir_absolute(COVER_PICTURE_PATH)

## 查询列 默认查询全部返回全部字段
func select_rows(conditions: String = "", columns: Array = columns) -> Array:
	
	return db.select_rows(TABLE_NAME, conditions, columns)

## 新增库
func insert_row(dict: Dictionary) -> bool:
	var success = db.insert_row(TABLE_NAME, dict)
	if success:
		change_video_gallery_array.emit()
	return success

## 更新库
func update_row(conditions: String, dict: Dictionary) -> bool:
	var success = db.update_rows(TABLE_NAME, conditions, dict)
	if success:
		change_video_gallery_array.emit()
	return success

# 删除库
func delete_row(conditions: String) -> bool:
	var success = db.delete_rows(TABLE_NAME, conditions)
	if success:
		change_video_gallery_array.emit()
	return success
