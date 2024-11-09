extends Window


## 窗口类型
enum Window_Type {
	CREATE,
	RENAME,
}

## 当前窗口类型
var current_type = Window_Type.CREATE

var video_gallery_id: int

@onready var title_label: Label = $PanelContainer/V/TitleMargin/TitleLabel
@onready var line_edit: LineEdit = $PanelContainer/V/EditMargin/LineEdit
@onready var confirm_button: Button = $PanelContainer/V/ExecuteMargin/H/ConfirmButton
@onready var cancel_button: Button = $PanelContainer/V/ExecuteMargin/H/CancelButton

func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	get_parent().modulate = Color(1, 1, 1, 0.5)
	line_edit.grab_focus()

## 初始化
func init_window(params: Dictionary) -> void:
	if "title_window" in params:
		title_label.text = params.title_window
	if "window_type" in params:
		current_type = params.window_type
	if "video_gallery_id" in params:
		video_gallery_id = params.video_gallery_id


func _exit_tree() -> void:
	get_parent().modulate = Color(1, 1, 1, 1)

func _on_cancel_button_pressed() -> void:
	queue_free()

func _on_confirm_button_pressed() -> void:
	match current_type:
		Window_Type.CREATE:
			var gallery_name := line_edit.text
			if gallery_name != "":
				var video_gallery = VideoGallery.new()
				video_gallery.video_gallery_name = gallery_name
				video_gallery.create_time = DateUtil.format_current_time()
				VideoGalleryService.insert(video_gallery)

		Window_Type.RENAME:
			var gallery_name := line_edit.text
			if gallery_name != "":
				var update_builder = UpdateBuilder.new()
				update_builder.eq("id", video_gallery_id)
				update_builder.set_column("video_gallery_name", gallery_name)
				VideoGalleryService.update(update_builder)
	queue_free()
