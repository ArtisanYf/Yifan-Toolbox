extends Node

# 当视频项列表发生变化时发出
signal change_video_item_array(type: Change_Array_Type, video_item: VideoItem)

# 视频列表变更信号类型
enum Change_Array_Type{
	QUERY,
	SAVE,
	UPDATE,
	DELETE,
}

# 视频项信息存放文件地址
const VIDEO_ITEM_PATH := "user://video_item.sav"

# 视频项图片目录
const COVER_PICTURE_PATH := "user://video_item_cover_picture/"

const PREVIEW_VIDEO_PATH :="user://video_item/preview/"

var db := DB.db

# 表名
const TABLE_NAME := "t_video_item"

# 字段名
var columns = [
	"id", "video_gallery_id",
	"video_name", "video_path", "cover_picture_path", "preview_path",
	"create_time", "labels", "outline","other_picture_paths","publish_time",
]

# 视频项列表
var video_item_array: Array

# 封面图片
var cover_picture_texture_array: Array

var texture_cache: Dictionary = {}

# 当前所选视频库
var current_video_item_array :Array

## 当前所选视频项
#var current_video_item :Dictionary:
	#set(v):
		#current_video_item = v
		#change_current_video_item.emit()

func _init() -> void:
	var table_dict: Dictionary = VideoItem.new().table_dict()
	# 通过 sql 检查表是否已存在
	db.query_with_bindings("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", [TABLE_NAME])
	if db.query_result.is_empty():
		# 创建表
		db.create_table(TABLE_NAME, table_dict)
	#else:
		#db.drop_table(TABLE_NAME)
		#db.create_table(TABLE_NAME, table_dict)

func _ready() -> void:
	print("视频项初始化...")
	# 静态创建目录
	DirAccess.make_dir_absolute(COVER_PICTURE_PATH)
	DirAccess.make_dir_absolute("user://video_item/")
	DirAccess.make_dir_absolute(PREVIEW_VIDEO_PATH)
	

## 查询列
func select_array(query_buildder: QueryBuilder) -> Array:
	var array := db.select_rows(TABLE_NAME, query_buildder.conditions, query_buildder.columns)
	var video_array = []
	for dict in array:
		video_array.append(VideoItem.new(dict))
	return video_array

## 查询列
func select_one(query_buildder: QueryBuilder) -> VideoItem:
	var array := db.select_rows(TABLE_NAME, query_buildder.conditions, query_buildder.columns)
	if array.is_empty():
		return null
	return VideoItem.new(array[0])
	
## 通过 id 查询
func select_by_id(id: int) -> VideoItem:
	return select_one(QueryBuilder.new().eq("id", id))
	
## 新增
func insert(video_item: VideoItem) -> bool:
	print(video_item.to_dict())
	var success = db.insert_row(TABLE_NAME, video_item.to_dict())
	if success:
		# 本次新增的 id
		video_item.id = db.last_insert_rowid
		change_video_item_array.emit(Change_Array_Type.SAVE, video_item)
	return success

## 批量新增
func insert_batch(array: Array) -> bool:
	var temp := []
	for video_item in array:
		temp.append(video_item.to_dict())
	var success = db.insert_rows(TABLE_NAME, temp)
	if success:
		change_video_item_array.emit(Change_Array_Type.QUERY, null)
	return success

## 更新
func update(update_builder: UpdateBuilder) -> bool:
	var success = db.update_rows(TABLE_NAME, update_builder.conditions, update_builder.dict)
	if success:
		change_video_item_array.emit(Change_Array_Type.UPDATE, VideoItem.new(update_builder.param))
	return success

# 删除
func delete(basic_builder: BasicBuilder) -> bool:
	var success = db.delete_rows(TABLE_NAME, basic_builder.conditions)
	if success:
		change_video_item_array.emit(Change_Array_Type.DELETE, null)
	return success

# 逻辑删除
func logic_delete(update_builder: UpdateBuilder) -> bool:
	if update_builder.table_logic:
		update_builder.dict[update_builder.table_logic] = 1
	var success = db.update_rows(TABLE_NAME, update_builder.conditions, update_builder.dict)
	if success:
		var video_item = VideoItem.new()
		video_item.id = update_builder.param.id
		change_video_item_array.emit(Change_Array_Type.DELETE, video_item)
	return success

# 逻辑删除根据id
func logic_delete_by_id(id: int) -> bool:
	return logic_delete(
		UpdateBuilder.new()
			.eq("id", id)
		)
		
## count
#func count(query_buildder: QueryBuilder) -> int:
	#db.c

# 标签统计
func label_statc(label_name: String = "") -> Array:
	var condition: String = ""
	if label_name:
		condition = "where label LIKE '%{0}%'".format([label_name])
	db.query_with_bindings("SELECT json_each.value AS label,COUNT(*) AS count FROM t_video_item,json_each(t_video_item.labels) " + condition + "GROUP BY label", [])
	print(db.query_result)
	return db.query_result
