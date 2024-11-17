class_name BaseEntity
extends RefCounted

## 实体基类


# 初始化对象，通过字典赋值属性
func _init(dict: Dictionary = {}):
	from_dict(dict)

# 校验是否是自定义属性
func is_custom_property(property_name):
	# 过滤掉可能不是自定义属性的条件
	var built_in_properties = ["RefCounted", "script", str(self.get_script().resource_path).get_file()]
	return not property_name.begins_with("_") and property_name not in built_in_properties and not property_name.ends_with(".gd")


# 将对象的属性转换为字典格式
func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	var property_list = get_property_list()
	for property in property_list:
		var property_name = property.name
		var property_type = property.type
		if property_name == "id" and get(property_name) == 0:
			continue
		if not is_custom_property(property_name):
			continue
			
		var property_value = get(property_name)
		if property_type == TYPE_ARRAY:
			property_value = str(property_value)
		dict[property_name] = property_value
	return dict
	
# 从字典格式还原为对象实例
func from_dict(data: Dictionary) -> void:
	var property_list = get_property_list()
	var property_types: Dictionary = {}
	for property in property_list:
		property_types[property.name] = property.type
		
	for property_name in data.keys():
		# 检查属性是否为自定义属性并且在当前对象中存在
		if is_custom_property(property_name) and has_method("set"):
			var value = data[property_name]
			# 根据属性类型进行还原
			if property_name in property_types and property_types[property_name] == TYPE_ARRAY and value is String:
				value = JSON.parse_string(value)  # 将字符串解析回数组
			set(property_name, value)

func table_dict() -> Dictionary:
	var dict: Dictionary = {}
	var property_list = get_property_list()
	for property in property_list:
		var property_name = property.name
		var property_type = property.type
		if not is_custom_property(property_name):
			continue
		var date_type: String
		if property_type == TYPE_INT:
			date_type = "int"
		elif property_type == TYPE_BOOL:
			date_type = "blob"
		else:
			date_type = "text"
		if property_name == "id":
			dict[property_name] = {
				"data_type": date_type,
				"primary_key": true,
				"auto_increment": true
			}
		else:
			dict[property_name] = {
				"data_type": date_type,
			}
	return dict
