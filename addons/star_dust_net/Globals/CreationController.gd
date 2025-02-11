extends Node

#resource id that should be used next
var _next_rid = 1
#list of node objects that got created
var _created_nodes = {}
#list of sync variable that can be resent to create the nodes
#on new clients
var _syncronization_data = {}

func create_net_node(res_path:String, scene_path:String, args:String):
	if(multiplayer.is_server()):
		var id = _next_rid
		_next_rid += 1
		rpc("_node_creation_local", res_path, scene_path, id, args)
		return id



#this should be used on the server to send a removal request to all clients
func remove_net_node(res_id:int):
	if(multiplayer.is_server()):
		rpc("_node_removal_local", res_id)

func get_created_node(res_id:int):
	if(_created_nodes.has(res_id)):
		return _created_nodes[res_id]
	else:
		return null

func clear_creation():
	#free the nodes
	for n in _created_nodes:
		_created_nodes[n].queue_free()
	
	#clear the arrays and reset the ids
	_next_rid = 1
	_created_nodes.clear()
	_syncronization_data.clear()

@rpc("authority", "call_local", "reliable")
func _node_removal_local(res_id:int):
	if(_created_nodes.has(res_id)):
		var node = _created_nodes[res_id]
		node.queue_free()
		_created_nodes.erase(res_id)
		_syncronization_data.erase(res_id)

#this rpc should be used to create nodes on both the server and client for
#when they are added to the world
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

#this rpc gets called when a new player joins the server to be able to bring
#them up to speed with all the nodes that exist in the world
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

#this function gets called when a new player joins to add all the network nodes
func sync_creation_new_player(id):
	if(multiplayer.is_server()):
		for i in _syncronization_data:
			var data = _syncronization_data[i]
			var node = _created_nodes[i]
			var a = node.get_updated_args()
			rpc_id(id, "_node_creation_remote", data["rp"], data["sp"], data["rid"], a)
