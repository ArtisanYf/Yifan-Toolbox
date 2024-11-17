extends Control

const VIDEO_SETTING_PAGE = preload("res://src/modules/local_video/setting/video_setting_page.tscn")
const HOME = "res://src/modules/home/home.tscn"

var menu_button_group := ButtonGroup.new()


@onready var home_button: Button = $V/H/MenuPanel/V/Margin/H/HomeButton
@onready var option_button: OptionButton = $V/H/MenuPanel/V/Margin/H/OptionButton
@onready var progress_bar: ProgressBar = $V/H/MenuPanel/V/ProgressBar
@onready var setting_button: Button = $V/H/MenuPanel/Margin/SettingButton
@onready var all_video_button: Button = $V/H/MenuPanel/V/AllVideoButton
@onready var tab_bar: TabBar = $V/H/ContentPanel/V/TabBar
@onready var v: VBoxContainer = $V/H/MenuPanel/V
@onready var content_v_box: VBoxContainer = $V/H/ContentPanel/V
@onready var video_performer_button: Button = $V/H/MenuPanel/V/VideoPerformerButton
@onready var video_performer_panel: VBoxContainer = $V/H/ContentPanel/V/VideoPerformerPanel
@onready var video_item_panel: VideoPanel = $V/H/ContentPanel/V/VideoItemPanel
@onready var video_label_button: Button = $V/H/MenuPanel/V/VideoLabelButton


func _ready() -> void:
	tab_bar.tab_selected.connect(func(tab: int):
		video_item_panel.visible = tab_bar.get_tab_title(tab) == all_video_button.text
		video_performer_panel.visible = tab_bar.get_tab_title(tab) == video_performer_button.text
	)
	tab_bar.tab_close_pressed.connect(func(tab: int): remove_tab_bar(tab))
	
	home_button.pressed.connect(_on_home_button_pressed)
	setting_button.pressed.connect(_on_setting_button_pressed)
	
	# todo
	option_button.item_selected.connect(_on_option_button_item_selected)
	var popup = option_button.get_popup()
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color.html("#202020")
	style_box.border_color = Color.html("#175bcc")
	style_box.border_width_bottom = 2
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_blend = true 
	style_box.corner_radius_bottom_left = 5
	style_box.corner_radius_bottom_right = 5
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	popup.transparent = true
	popup.visibility_changed.connect(func(): popup.size.x = option_button.size.x)
	popup.add_theme_stylebox_override("panel", style_box)
	
	
	TaskService.progress_signal.connect(func(value, _task_name):
		progress_bar.value = value
	)
	for video_gallery: VideoGallery in VideoGalleryService.select_array(QueryBuilder.new()):
		option_button.add_item(video_gallery.video_gallery_name, video_gallery.id)
		if video_gallery.id == VideoGalleryService.current_video_gallery.id:
			option_button.selected = option_button.get_item_index(video_gallery.id)
	
	menu_button_group.pressed.connect(func(button: Button):
		set_tab_bar(button.text, button.icon)
	)
	video_performer_button.button_group = menu_button_group
	all_video_button.button_group = menu_button_group
	video_label_button.button_group = menu_button_group
	all_video_button.button_pressed = true

# 设置 tab ber
func set_tab_bar(tab_title: String, tab_icon: Texture2D) -> void:
	for i in range(0, tab_bar.tab_count):
		if tab_bar.get_tab_title(i) == tab_title:
			tab_bar.current_tab = i
			return
	tab_bar.add_tab(tab_title, tab_icon)
	tab_bar.current_tab = 0 if tab_bar.tab_count == 0 else tab_bar.tab_count - 1
	pass
	
# 移除 tab ber
func remove_tab_bar(tab: int) -> void:
	var tab_title := tab_bar.get_tab_title(tab)
	if tab_title == all_video_button.text:
		video_item_panel.visible = false
	if tab_title == video_performer_button.text:
		video_performer_panel.visible = false
	tab_bar.remove_tab(tab)
	
func _on_home_button_pressed() -> void:
	var tree := get_tree()
	VideoGalleryService.current_video_gallery = null
	tree.change_scene_to_file(HOME)
	
func _on_setting_button_pressed() -> void:
	get_tree().current_scene.add_child(VIDEO_SETTING_PAGE.instantiate())
	
func _on_option_button_item_selected(index: int) -> void:
	var video_gallery := VideoGallery.new()
	video_gallery.id = option_button.get_item_id(index)
	video_gallery.video_gallery_name = option_button.get_item_text(index)
	VideoGalleryService.current_video_gallery = video_gallery
