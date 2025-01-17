extends Node

var _next_rid = 1
var _created_nodes = {}
var _syncronization_data = {}

func create_net_node(res_path:String, scene_path:String, args:String):
	if(multiplayer.is_server()):
		var id = _next_rid
		_next_rid += 1
		rpc("_node_creation_local", res_path, scene_path, id, args)

func remove_net_node(res_id:int):
	if(multiplayer.is_server()):
		rpc("_node_removal_local", res_id)

@rpc("authority", "call_local", "reliable")
func _node_removal_local(res_id:int):
	if(_created_nodes.has(res_id)):
		var node = _created_nodes[res_id]
		node.queue_free()
		_created_nodes.erase(res_id)

@rpc("authority", "call_local", "reliable")
func _node_creation_local(res_path:String, scene_path:String, res_id:int, args:String):
	if(multiplayer.get_remote_sender_id() == 1):
		var node:Node = load(res_path).instantiate()
		#----------------------------------------------------------------
		#these are going to be some magic functions for creating nodes in the network
		#maybe some day I will come up with a better idea but this should work
		node.handle_args(args)
		node.set_res_id(res_id)
		#--------------------------------------------------------------------
		var nn = get_node(NodePath(scene_path))
		if(nn == null):
			print("Scene Path: " + scene_path + " is incorrect that nodes does not exist")
		else:
			nn.add_child(node)
			_created_nodes[res_id] = node
			_syncronization_data[res_id] = {"rp":res_path, "sp":scene_path, "rid":res_id, "a":args}

@rpc("authority", "call_remote", "reliable")
func _node_creation_remote(res_path:String, scene_path:String, res_id:int, args:String):
	if(multiplayer.get_remote_sender_id() == 1):
		var node:Node = load(res_path).instantiate()
		#----------------------------------------------------------------
		#these are going to be some magic functions for creating nodes in the network
		#maybe some day I will come up with a better idea but this should work
		node.handle_args(args)
		node.set_res_id(res_id)
		#--------------------------------------------------------------------
		get_node(NodePath(scene_path)).add_child(node)
		_created_nodes[res_id] = node
		_syncronization_data[res_id] = {"rp":res_path, "sp":scene_path, "rid":res_id, "a":args}

func sync_creation_new_player(id):
	if(multiplayer.is_server()):
		for i in _syncronization_data:
			var data = _syncronization_data[i]
			rpc_id(id, "_node_creation_remote", data["rp"], data["sp"], data["rid"], data["a"])
