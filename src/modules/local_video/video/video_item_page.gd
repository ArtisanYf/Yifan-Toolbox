extends Control

const HOME = "res://src/modules/home/home.tscn"
@onready var home_button: Button = $V/H/MenuPanel/V/Margin/H/HomeButton
@onready var option_button: OptionButton = $V/H/MenuPanel/V/Margin/H/OptionButton
@onready var progress_bar: ProgressBar = $V/H/MenuPanel/V/ProgressBar

func _ready() -> void:
	home_button.pressed.connect(_on_home_button_pressed)
	option_button.item_selected.connect(_on_option_button_item_selected)
	TaskService.progress_signal.connect(func(value, task_name):
		progress_bar.value = value
	)
	for video_gallery: VideoGallery in VideoGalleryService.select_array(QueryBuilder.new()):
		option_button.add_item(video_gallery.video_gallery_name, video_gallery.id)
		if video_gallery.id == VideoGalleryService.current_video_gallery.id:
			option_button.selected = option_button.get_item_index(video_gallery.id)
	
	
func _on_home_button_pressed() -> void:
	var tree := get_tree()
	VideoGalleryService.current_video_gallery = null
	tree.change_scene_to_file(HOME)


func _on_option_button_item_selected(index: int) -> void:
	var video_gallery := VideoGallery.new()
	video_gallery.id = option_button.get_item_id(index)
	video_gallery.video_gallery_name = option_button.get_item_text(index)
	VideoGalleryService.current_video_gallery = video_gallery
