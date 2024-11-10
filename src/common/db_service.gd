class_name DBService
extends Node

# 表名
var table_name: String

var db: SQLite

## 查询列
func select_array(query_buildder: QueryBuilder, cls_ref) -> Array:
	var array := db.select_rows(table_name, query_buildder.conditions, query_buildder.columns)
	var gallery_array = []
	for dict in array:
		gallery_array.append(cls_ref.new(dict))
	return gallery_array

## 查询列
func select_one(query_buildder: QueryBuilder, cls_ref) -> VideoGallery:
	var array := db.select_rows(table_name, query_buildder.conditions, query_buildder.columns)
	if array.is_empty():
		return null
	return cls_ref.new(array[0])
	
## 新增库
func insert(obj) -> bool:
	var success = db.insert_row(table_name, obj.to_dict())
	return success

## 更新库
func update(update_builder: UpdateBuilder) -> bool:
	var success = db.update_rows(table_name, update_builder.conditions, update_builder.dict)
	return success

# 删除库
func delete(basic_builder: BasicBuilder) -> bool:
	var success = db.delete_rows(table_name, basic_builder.conditions)
	return success

# 逻辑删除
func logic_delete(update_builder: UpdateBuilder) -> bool:
	if update_builder.table_logic != "":
		update_builder.dict[update_builder.table_logic] = 1
	var success = db.update_rows(table_name, update_builder.conditions, update_builder.dict)
	return success
