extends Node

# db
var db := SQLite.new()

func _init() -> void:
	# 库路径
	db.path = "user://yifan_tool"
	
	# QUIET 不要在控制台上打印任何内容
	# NORMAL 将基本信息打印到控制台
	# VERBOSE 将其他信息打印到控制台
	# VERY_VERBOSE 与VERBOSE相同
	db.verbosity_level = SQLite.VerbosityLevel.VERBOSE
	
	# 打开一个新的数据库连接。同一数据库可能存在多个并发打开的连接。
	db.open_db()
