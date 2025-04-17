@tool
extends EditorPlugin

var script_builder_doc

func _enter_tree():
	if(!DirAccess.dir_exists_absolute("res://NetNodes/")):
		DirAccess.make_dir_absolute("res://NetNodes/")
	
	add_autoload_singleton("NetController", "res://addons/star_dust_net/Globals/NetController.gd")
	add_autoload_singleton("FrameSyncController", "res://addons/star_dust_net/Globals/FrameSyncController.gd")
	add_autoload_singleton("CreationController", "res://addons/star_dust_net/Globals/CreationController.gd")
	add_autoload_singleton("StarDustUtil", "res://addons/star_dust_net/Globals/StarDustUtils.gd")
	script_builder_doc = preload("res://addons/star_dust_net/Docks/ScriptBuilder.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, script_builder_doc)

func _exit_tree():
	remove_autoload_singleton("NetController")
	remove_autoload_singleton("FrameSyncController")
	remove_autoload_singleton("CreationController")
	
	remove_control_from_docks(script_builder_doc)
	script_builder_doc.free()
