class_name BasicBuilder
extends RefCounted


var conditions: String = ""

var param = {}

func eq(column: String, value) -> BasicBuilder:
	conditions += " ".join(["",column, "=", value])
	param[column] = value
	return self
