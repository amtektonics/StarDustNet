@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("NetController", "res://addons/star_dust_net/Globals/NetController.gd")
	add_autoload_singleton("FrameSyncController", "res://addons/star_dust_net/Globals/FrameSyncController.gd")
	add_autoload_singleton("CreationController", "res://addons/star_dust_net/Globals/CreationController.gd")
func _exit_tree():
	remove_autoload_singleton("NetController")
	remove_autoload_singleton("FrameSyncController")
	remove_autoload_singleton("CreationController")
