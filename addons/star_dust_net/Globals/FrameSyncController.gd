extends Node

var _sync_count = 1

var _sync_nodes:Array[SyncNode] = []

var _stored_frames:Dictionary = {}

var _timers = []

#a delay in seconds to wait for the client to get all of the sync object up and running
var _peer_wait_delay = 0.1

func _ready():
	randomize()
	NetController.player_connected.connect(_player_connected)

func register_sync_node(node:SyncNode):
	if(NetController.is_net_connected()):
		if(multiplayer.is_server()):
			node.sync_id = _sync_count
			_sync_count += 1
			_sync_nodes.append(node)
			rpc("_register_sync_node", node.get_path(), node.sync_id)

func remove_sync_node(node_id:int):
	for s:SyncNode in _sync_nodes:
		if(s.sync_id == node_id):
			_sync_nodes.erase(s)
			break

func has_sync_node_id(node_id:int):
	for s:SyncNode in _sync_nodes:
		if(s.sync_id == node_id):
			return true
	return false

func get_sync_node(node_id:int):
	for s:SyncNode in _sync_nodes:
		if(s.sync_id == node_id):
			return s
	return null

func _player_connected(id):
	#nodes need to exist before they are syncronized
	CreationController.sync_creation_new_player(id)
	for s in _sync_nodes:
		rpc_id(id,"_register_sync_node", s.get_path(), s.sync_id)
	if(multiplayer.is_server()):
		_start_peer_setup_delay(id)
	

func _start_peer_setup_delay(peer_id:int):
	var timer = NamedTimer.new()
	timer.name = str(peer_id)
	timer.autostart = true
	timer.wait_time = _peer_wait_delay
	timer.one_shot = true
	timer.named_timeout.connect(_peer_setup_timeout)
	add_child(timer)
	_timers.append(timer)

func _peer_setup_timeout(name:String):
	for i in _stored_frames:
		for j in _stored_frames[i]:
			rpc_id(int(name), "send_reliable_frame", j)
	
	var t = _timers.pop_front()
	t.queue_free()

#rpc methods
@rpc("any_peer", "call_remote", "reliable")
func _register_sync_node(node_path:NodePath, sync_id:int):
	
	var node = get_node(node_path)
	if(node == null):
		print("Node missing unable to register: sync id " + str(sync_id))
	else:
		node.sync_id = sync_id
		_sync_nodes.append(node)


#all the send frame rpcs are different forms of sending a 
#sync data with unreliable reliable and and it needs to be called locally
#first one is documented to help it make sense
@rpc("any_peer", "call_remote", "reliable")
func send_reliable_frame(frame:String, store=false):
	#data comes in as a json string the type is a generic SyncData
	#but other data type can inheret it the only bit we are concerned about
	#is the sid or sync node id
	var data = JSON.parse_string(frame)
	var sid = data["sid"]
	
	#sync nodes are assigned by the server an id so we are making sure we
	#have it present on this peer
	if(has_sync_node_id(sid)):
		#if store is true the frame will also be stored to be resent later
		#the server is the responsible party to send this on a client connect
		if(store && multiplayer.is_server()):
			if(!_stored_frames.has(sid)):
				_stored_frames[sid] = []
			_stored_frames[sid].append(frame)
		var node:SyncNode = get_sync_node(sid)
		
		node.add_frame_data(frame)

@rpc("any_peer", "call_remote", "unreliable")
func send_unreliable_frame(frame:String, store=false):
	var data = JSON.parse_string(frame)
	var sid = data["sid"]
	
	if(has_sync_node_id(sid)):
		if(store && multiplayer.is_server()):
			if(!_stored_frames.has(sid)):
				_stored_frames[sid] = []
			_stored_frames[sid].append(frame)
		var node:SyncNode = get_sync_node(sid)
		
		node.add_frame_data(frame)

@rpc("any_peer", "call_local", "reliable")
func send_reliable_frame_local(frame:String, store=false):
	var data = JSON.parse_string(frame)
	var sid = data["sid"]
	
	if(has_sync_node_id(sid)):
		if(store && multiplayer.is_server()):
			if(!_stored_frames.has(sid)):
				_stored_frames[sid] = []
			_stored_frames[sid].append(frame)
		var node:SyncNode = get_sync_node(sid)
		
		node.add_frame_data(frame)

@rpc("any_peer", "call_local", "unreliable")
func send_unreliable_frame_local(frame:String, store=false):
	var data = JSON.parse_string(frame)
	var sid = data["sid"]
	
	if(has_sync_node_id(sid)):
		if(store && multiplayer.is_server()):
			if(!_stored_frames.has(sid)):
				_stored_frames[sid] = []
			_stored_frames[sid].append(frame)
		var node:SyncNode = get_sync_node(sid)
		
		node.add_frame_data(frame)
