@tool 

extends Control

@onready var _window = $Window

@onready var _dialog = $Window/PopupSyncControl


func _on_add_new_sync_data_pressed():
	_window.title = "Add new Sync and Data Scripts"
	_window.visible = true
	_dialog.set_input_mode(1)


func _on_add_new_res_pressed():
	_window.title = "Add new Creation Resource Script"
	_window.visible = true
	_dialog.set_input_mode(2)


func _on_add_new_sync_res_data_pressed():
	_window.title = "Add new Sync Data and Creation Resource Scripts"
	_window.visible = true
	_dialog.set_input_mode(3)
