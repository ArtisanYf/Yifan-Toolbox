class_name QueryBuilder
extends BasicBuilder

var columns: Array = ["*"]

# 设置查询字段
func select(_columns: Array) -> QueryBuilder:
	columns = _columns
	return self

func orderByDesc(column: String) -> QueryBuilder:
	if conditions == "":
		conditions += "1 = 1"
	conditions += " ".join([" ORDER BY", column, "Desc"])
	return self

func orderByAsc(column: String) -> QueryBuilder:
	if conditions == "":
		conditions += "1 = 1"
	conditions += " ".join([" ORDER BY", column, "Asc"])
	return self

func orderByRandom() -> QueryBuilder:
	if conditions == "":
		conditions += "1 = 1"
	conditions += " ".join([" ORDER BY RANDOM()"])
	return self
