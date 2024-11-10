class_name VideoGalleryItem
extends PanelContainer

signal right_click(id: int)

const THEME_TYPE = "VideoGalleryItem"

const VIDEO_ITEM_PAGE = "res://src/modules/local_video/video/video_item_page.tscn"

var video_gallery: VideoGallery

var styles_box: StyleBoxFlat
var is_loading_icon = false

var cover_picture_texture: Texture2D:
	set(v):
		cover_picture_texture = v
		icon.texture = cover_picture_texture

@onready var icon: TextureRect = $H/Margin/Icon
@onready var name_label: Label = $H/V/NameLabel
@onready var time_label: Label = $H/V/TimeLabel
@onready var double_click_timer: Timer = $DoubleClickTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pass


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			# 双击切换场景
			if double_click_timer.is_stopped():
				double_click_timer.start()
			else:
				var tree := get_tree()
				VideoGalleryService.current_video_gallery = video_gallery
				tree.change_scene_to_file(VIDEO_ITEM_PAGE)
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and event.pressed:
			right_click.emit(video_gallery.id)

func refresh_video_gallery(_video_gallery: VideoGallery) -> void:
	init_video_gallery(_video_gallery)
	if video_gallery.cover_picture_path != "":
		cover_picture_texture = TextureUtil.create_texture(video_gallery.cover_picture_path)
	is_loading_icon = true

## 实例化本场景时需要调用
func init_video_gallery(_video_gallery: VideoGallery) -> void:
	video_gallery = _video_gallery
	name_label.text = video_gallery.video_gallery_name
	time_label.text = video_gallery.create_time


func _on_mouse_entered() -> void:
	styles_box = get_theme_stylebox("panel", THEME_TYPE)
	add_theme_stylebox_override("panel", get_theme_stylebox("hover", THEME_TYPE))	

func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", styles_box)
	#double_click_timer.stop()
