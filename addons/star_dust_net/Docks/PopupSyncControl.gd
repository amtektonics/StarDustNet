@tool

extends Control

@onready var _window = get_parent()

@onready var _file_name = $FileNameInput
@onready var _path = $PathInput

var _sync_node_folder = "SyncNodes"

var _sync_data_folder = "SyncDataNodes"

var _creation_res_folder = "CreationNodes"

# 1 is a new sync node with a matching data node
# 2 is a new creation resource node
# 4 is a new sync node with matching data that is also a creation node
var _input_mode = 0

func set_input_mode(value:int):
	_input_mode = value

func _on_window_close_requested():
	_window.visible = false


func _on_cancel_pressed():
	_window.visible = false

func _build_file_structure(path:String):
	if(!DirAccess.dir_exists_absolute(path)):
		DirAccess.make_dir_absolute(path)
	
	if(!DirAccess.dir_exists_absolute(path.path_join(_sync_node_folder))):
		DirAccess.make_dir_absolute(path.path_join(_sync_node_folder))
	
	
	if(!DirAccess.dir_exists_absolute(path.path_join(_sync_data_folder))):
		DirAccess.make_dir_absolute(path.path_join(_sync_data_folder))
	
	if(!DirAccess.dir_exists_absolute(path.path_join(_creation_res_folder))):
		DirAccess.make_dir_absolute(path.path_join(_creation_res_folder))

func _on_confirm_pressed():
	_build_file_structure(_path.text)
	var dir = DirAccess.open(_path.text)
	var sync_f_path = _path.text.path_join(_sync_node_folder).path_join(_file_name.text) + "SyncNode.gd"
	var sync_d_path = _path.text.path_join(_sync_data_folder).path_join(_file_name.text) + "SyncData.gd"
	var creation_path = _path.text.path_join(_creation_res_folder).path_join(_file_name.text) + "CreationResource.gd"
	match(_input_mode):
		1:
			var syncf = FileAccess.open(sync_f_path, FileAccess.WRITE)
			var syncd = FileAccess.open(sync_d_path, FileAccess.WRITE)
			
			syncf.store_string(_get_sync_node_template())
			syncd.store_string(_get_sync_data_template())
			
			syncf.close()
			syncd.close()
		
		2:
			var creation_r = FileAccess.open(creation_path, FileAccess.WRITE)
			
			creation_r.store_string(_get_creation_resource_template())
			
			creation_r.close()
		
		3:
			var creation_sr = FileAccess.open(creation_path, FileAccess.WRITE)
			var syncd = FileAccess.open(sync_d_path, FileAccess.WRITE)
			
			creation_sr.store_string(_get_sync_creation_resource_template())
			syncd.store_string(_get_sync_data_template())
			
			creation_sr.close()
			syncd.close()
	
	EditorFileDialog
	_file_name.text = ""
	_window.visible = false
	EditorInterface.get_resource_filesystem().scan()
	


func _get_sync_node_template():
	var file = FileAccess.open("res://addons/star_dust_net/Templates/SyncNodeTemplate.txt", FileAccess.READ)
	var text = file.get_as_text()
	var result = text.replace("@@", _file_name.text)
	return result

func _get_sync_data_template():
	var file = FileAccess.open("res://addons/star_dust_net/Templates/SyncDataTemplate.txt", FileAccess.READ)
	var text = file.get_as_text()
	var result = text.replace("@@", _file_name.text)
	return result

func _get_creation_resource_template():
	var file = FileAccess.open("res://addons/star_dust_net/Templates/CreationResourceTemplate.txt", FileAccess.READ)
	var text = file.get_as_text()
	var result = text.replace("@@", _file_name.text)
	return result

func _get_sync_creation_resource_template():
	var file = FileAccess.open("res://addons/star_dust_net/Templates/SyncCreationTemplate.txt", FileAccess.READ)
	var text = file.get_as_text()
	var result = text.replace("@@", _file_name.text)
	return result
