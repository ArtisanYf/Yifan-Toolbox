extends Window

var pic_button_gourp := ButtonGroup.new()
var menu_button_gourp := ButtonGroup.new()
var video_info_button_group := ButtonGroup.new()

var video_item: VideoItem

@onready var close_button: Button = $Panel/V/TopMargin/H/CloseButton
@onready var poster_button: Button = $Panel/V/H/LeftMargin/V/PosterButton
@onready var preview_button: Button = $Panel/V/H/LeftMargin/V/PreviewButton
@onready var name_label: Label = $Panel/V/TopMargin/TitleHBox/NameLabel
@onready var pic_h_box: HBoxContainer = $Panel/V/H/MainMargin/MainVBox/PicMargin/PicPanel/Scroll/PicHBox
@onready var texture_rect: TextureRect = $Panel/V/H/MainMargin/MainVBox/TextureRect
@onready var film_info_button: Button = $Panel/V/H/VideoInfoMargin/V/MarginContainer/H/FilmInfoButton
@onready var video_info_button: Button = $Panel/V/H/VideoInfoMargin/V/MarginContainer/H/VideoInfoButton
@onready var play_button: Button = $Panel/V/H/VideoInfoMargin/Margin/PlayButton


@onready var video_info_v_box: VBoxContainer = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox
@onready var format_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoFormatHBox/FormatValueLabel
@onready var duration_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoDurationHBox/DurationValueLabel
@onready var frame_rate_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoFrameRateHBox/FrameRateValueLabel
@onready var bit_rate_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoBitRateHBox/BitRateValueLabel
@onready var resolution_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoResolutionHBox/ResolutionValueLabel
@onready var aspect_ratio_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoAspectRatioHBox/AspectRatioValueLabel
@onready var bits_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoBitsHBox/BitsValueLabel
@onready var total_frame_rate_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoTotalFrameRateHBox/TotalFrameRateValueLabel
@onready var audio_codec_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/AudioCodecHBox/AudioCodecValueLabel
@onready var audio_bit_rate_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/AudioBitRateHBox/AudioBitRateValueLabel
@onready var audio_sample_rate_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/AudioSampleRateHBox/AudioSampleRateValueLabel
@onready var audio_channels_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/AudioChannelsRateHBox/AudioChannelsValueLabel
@onready var file_suffix_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/FileSuffixHBox/FileSuffixValueLabel
@onready var file_size_value_label: Label = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/FileSizeHBox/FileSizeValueLabel
@onready var file_location_button: LinkButton = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/FileLocationButton
@onready var video_info_copy_button: Button = $Panel/V/H/VideoInfoMargin/V/VideoInfoVBox/VideoCopyMargin/VideoInfoCopyButton


func _ready() -> void:
	close_button.pressed.connect(func(): queue_free())
	poster_button.button_group = menu_button_gourp
	preview_button.button_group = menu_button_gourp
	
	menu_button_gourp.pressed.connect(func(button: Button):
		if button == poster_button:
			init_poster()
		if button == preview_button:
			init_preview()
	)
	
	film_info_button.button_group = video_info_button_group
	video_info_button.button_group = video_info_button_group
	
	video_info_button_group.pressed.connect(func(button: Button):
		if button == film_info_button:
			video_info_v_box.visible = false
		if button == video_info_button:
			video_info_v_box.visible = true
	)
	
	pic_button_gourp.pressed.connect(func(button: Button): texture_rect.texture = button.icon)
	
	video_info_copy_button.pressed.connect(func():
		var copy_text: String = ""
		for h_box in video_info_v_box.get_children():
			if not h_box is HBoxContainer:
				continue
			for label in h_box.get_children():
				if label is Label:
					copy_text += label.text	
			copy_text += "\n"
		DisplayServer.clipboard_set(copy_text)
	)
	
	play_button.pressed.connect(func(): SystemSettings.play_video(video_item.video_path))

# 场景初始化	
func init_scene(_video_item: VideoItem) -> void:
	video_item = _video_item
	await get_tree().process_frame
	await get_tree().process_frame
	name_label.text = video_item.video_name
	title = video_item.video_name
	poster_button.button_pressed = true
	video_info_button.button_pressed = true
	init_video_info()

# 视频海报图初始化
func init_poster() -> void:
	#await get_tree().process_frame
	for button in pic_h_box.get_children():
		button.queue_free()
	var button = PicButton.new()
	button.button_group = pic_button_gourp
	button.custom_minimum_size = Vector2((pic_h_box.size.y) / 9 * 16, pic_h_box.size.y)
	button.icon_changed.connect(func(icon):
		texture_rect.texture = icon
	)
	# 创建任务加载预览图片
	pic_h_box.add_child(button)
	button.button_pressed = true
	TaskService.add_task(TaskService.Task_Type.LOAD_TEXTURE, {
		"nodes" = [button],
		"datas" = [{cover_picture_path = video_item.cover_picture_path}],
		"texture_field" = "cover_picture_path",
		"texture_property" = "custom_icon",
	})

# 视频预览图初始化
func init_preview() -> void:
	var buttons: Array = []  # 用于保存按钮的数组
	# 清理现有子节点
	for node in pic_h_box.get_children():
		node.queue_free()
	
	if not video_item.preview_path:
		return
	var files := DirAccess.get_files_at(video_item.preview_path)
	var data_array := []
	# 创建按钮并添加到 UI
	for i in range(0, files.size()):
		var button = PicButton.new()
		pic_h_box.add_child(button)
		button.button_group = pic_button_gourp
		button.custom_minimum_size = Vector2((pic_h_box.size.y) / 9 * 16, pic_h_box.size.y)
		if i == 0:
			button.button_pressed = true
			button.icon_changed.connect(func(icon):
				texture_rect.texture = icon
			)
		# 先将按钮保存到数组中
		buttons.append(button)
		data_array.append({
			icon_path = video_item.preview_path + files[i]
		})
	# 创建任务加载预览图片
	TaskService.add_task(TaskService.Task_Type.LOAD_TEXTURE, {
		"nodes" = buttons,
		"datas" = data_array,
		"texture_field" = "icon_path",
		"texture_property" = "custom_icon",
	})

# 视频信息初始化
func init_video_info() -> void:
	var video_path := video_item.video_path
	if not video_path:
		return
	var is_exist := FileAccess.file_exists(video_path)
	if not is_exist:
		return
	var video_info_dict := FFmpegUtil.get_video_info(SystemSettings.video_setting.ffprobe_path, video_path)
	if not video_info_dict:
		return
	# 假设 streams[0] 是音频，streams[1] 是视频，判断是否存在宽度信息
	var video_index = 1 if "width" in video_info_dict.streams[1] else 0
	var audio_index = 0 if video_index == 1 else 1
	
	# 视频格式
	format_value_label.text = video_info_dict.streams[video_index].codec_name
	
	# 时长
	duration_value_label.text = DateUtil.format_time_H_MN_S_MS(float(video_info_dict.format.duration))
	
	# 帧率
	var parts = video_info_dict.streams[video_index].avg_frame_rate.split("/")
	var numerator = float(parts[0])
	var denominator = float(parts[1])
	frame_rate_value_label.text = str(roundf(numerator / denominator)) + " FPS"
	
	# 总码率
	bit_rate_value_label.text = convert_bit_depth(float(video_info_dict.streams[video_index].bit_rate))
	
	# 分辨率
	var width = int(video_info_dict.streams[video_index].width)
	var height = int(video_info_dict.streams[video_index].height)
	resolution_value_label.text = str(width) + "x" + str(height)
	
	# 宽高比
	var gcd_value = gcd(width, height)
	@warning_ignore("integer_division")
	var simplified_width = width / gcd_value  # 宽度除以 GCD
	@warning_ignore("integer_division")
	var simplified_height = height / gcd_value  # 高度除以 GCD
	aspect_ratio_value_label.text = str(simplified_width) + ":" + str(simplified_height)
	
	# 位深度
	bits_value_label.text = video_info_dict.streams[video_index].bits_per_raw_sample + " bits"
	
	# 总帧率
	total_frame_rate_value_label.text = video_info_dict.streams[video_index].nb_frames
	
	# ------------
	# 音频格式
	audio_codec_value_label.text = video_info_dict.streams[audio_index].codec_name
	
	# 音频码率
	audio_bit_rate_value_label.text = convert_bit_depth(float(video_info_dict.streams[audio_index].bit_rate))
	
	# 采样率
	audio_sample_rate_value_label.text = convert_sample_rate(float(video_info_dict.streams[audio_index].sample_rate))
	
	# 通道
	audio_channels_value_label.text = str(video_info_dict.streams[audio_index].channels)
	
	# 文件后缀
	file_suffix_value_label.text = video_path.get_extension().to_upper()
	
	# 文件大小
	file_size_value_label.text = convert_file_size(float(video_info_dict.format.size))
	
	# 文件路径
	if video_item.video_name.length() > 30:
		file_location_button.text = video_item.video_name.substr(0, 30) + "..."
		file_location_button.tooltip_text = video_item.video_name
	else:
		file_location_button.text = video_item.video_name
	file_location_button.uri = video_path

# 计算 GCD
func gcd(a: int, b: int) -> int:
	while b != 0:
		var temp = b
		b = a % b
		a = temp
	return a

# bit 转换
func convert_bit_depth(bit_rate: float) -> String:
	var units = ["bps", "Kbps", "Mbps", "Gbps"]
	var index = 0
	
	while bit_rate >= 1000 and index < units.size() - 1:
		bit_rate /= 1000.0
		index += 1
	return str(roundf(bit_rate * 100) / 100) + " " + units[index]

# bytes 转换
func convert_file_size(bytes: float) -> String:
	var units = ["bytes", "KB", "MB", "GB", "TB"]
	var index = 0
	
	while bytes >= 1024 and index < units.size() - 1:
		bytes /= 1024.0
		index += 1
	
	# 使用 roundf 来保留两位小数并格式化为字符串
	return str(roundf(bytes * 100) / 100) + " " + units[index]

# hz 转换
func convert_sample_rate(hz: float) -> String:
	if hz < 1000:
		return str(hz) + " Hz"  # 小于 1000 Hz 使用 Hz
	else:
		var float_hz = float(hz) / 1000.0  # 转换为 kHz
		return str(roundf(float_hz * 100) / 100) + " KHz"  # 保留两位小数并格式化为字符串
