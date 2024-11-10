class_name BasicBuilder
extends RefCounted


var conditions: String = ""

var param = {}

# 逻辑删除字段
var table_logic = "is_deleted"

func _init() -> void:
	if table_logic != "":
		conditions += table_logic + " = 0"

func eq(column: String, value) -> BasicBuilder:
	var array := []
	if conditions == "":
		array = ["" ,column, "=", value]
	else: 
		array = [" and", column, "=", value]
	conditions += " ".join(array)
	param[column] = value
	return self

func like(column: String, value, condition: bool = true) -> BasicBuilder:
	if not condition:
		return self
	var array := ["", column, "like", "('%" + value + "%')"]
	if conditions != "":
		array[0] = " and"
	conditions += " ".join(array)
	param[column] = value
	return self
#
#func like1(column: String, value) -> BasicBuilder:
	#var condition_part = " and %s like ('%%s%%')" % [column, value]
	#
	#if conditions == "":
		#conditions = condition_part.strip_edges()  # 如果没有条件，直接赋值
	#else:
		#conditions += condition_part  # 如果已有条件，拼接新条件
#
	#param[column] = value
	#return self
