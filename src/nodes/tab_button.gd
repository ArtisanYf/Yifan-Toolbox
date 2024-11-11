class_name TabButton
extends Button

signal change_tab_button_pressed

var tab_button_pressed = false:
	set(v):
		tab_button_pressed = v
		button_pressed = v
		change_tab_button_pressed.emit(tab_button_pressed)
