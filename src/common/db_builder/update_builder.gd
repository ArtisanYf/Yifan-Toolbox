class_name UpdateBuilder
extends BasicBuilder

# 修改字段
var dict = {}


func set_column(column: String, value) -> UpdateBuilder:
	dict[column] = value
	return self
