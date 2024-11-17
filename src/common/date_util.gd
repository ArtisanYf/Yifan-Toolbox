class_name DateUtil
extends Node


# 格式化当前时间
static func format_current_time() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	
	# 确保月、日、小时、分钟和秒是两位数格式
	var year = str(datetime.year)
	var month = str(datetime.month)
	var day = str(datetime.day)
	var hour = str(datetime.hour)
	var minute = str(datetime.minute)
	var second = str(datetime.second)
	
	# 如果数字是个位数，则在前面补0
	if month.length() == 1:
		month = "0" + month
	if day.length() == 1:
		day = "0" + day
	if hour.length() == 1:
		hour = "0" + hour
	if minute.length() == 1:
		minute = "0" + minute
	if second.length() == 1:
		second = "0" + second
	
	# 格式化时间字符串
	var format_time_str = "{0}-{1}-{2} {3}:{4}:{5}".format([year, month, day, hour, minute, second])
	return format_time_str

# 秒转 
static func format_time_H_MN_S_MS(seconds: float) -> String:
	if seconds == 0.0:
		return ""
	# 获取小时、分钟、秒和毫秒
	var hours = int(seconds / 3600)
	var minutes = int(seconds / 60) % 60
	var remaining_seconds = int(seconds) % 60
	var milliseconds = int((seconds - int(seconds)) * 1000)
	
	# 格式化为 "Xh Ymn Zs Wms" 格式
	var time_string := ""
	
	# 添加小时（如果大于 0）
	if hours > 0:
		time_string += str(hours) + "h "
	
	# 添加分钟
	time_string += str(minutes) + "mn "
	
	# 添加秒
	time_string += str(remaining_seconds) + "s "
	
	# 添加毫秒
	time_string += str(milliseconds) + "ms"
	
	return time_string

# 当前时间戳
static func unix_current_time() -> int:
	var datetime = Time.get_datetime_dict_from_system()
	return Time.get_unix_time_from_datetime_dict(datetime)

# 毫秒转 小时分秒 
static func milliseconds_to_hh_mm_ss(seconds: float) -> String:
	var hours = int(seconds / 3600)
	var minutes = int(seconds / 60) % 60
	var remaining_seconds = int(seconds) % 60
	return "%02d:%02d:%02d" % [hours, minutes, remaining_seconds]

# 给予指定时长 -》划分指定段数
static func get_hh_mm_ss_intervals(seconds: float, segment: int) -> Array:
	if seconds < segment:
		segment = int(seconds)
	var interval_s = int(seconds / segment)  # 每个时间段的秒数
	var intervals = []
	for i in range(segment):
		var time_point = interval_s * i
		intervals.append(milliseconds_to_hh_mm_ss(time_point))
	return intervals
