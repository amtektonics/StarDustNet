extends Node

var _sync_count = 1

var _max_input_frames = 5

var _sync_nodes:Array[SyncNode] = []

var _stored_frames:Dictionary = {}

var _timers = []

var _inputs = {}

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
	_clean_client_sync_nodes()
	for s:SyncNode in _sync_nodes:
		if(s.sync_id == node_id):
			return true
	return false

func get_sync_node(node_id:int):
	_clean_client_sync_nodes()
	for s:SyncNode in _sync_nodes:
		if(s.sync_id == node_id):
			return s
	return null

func _clean_client_sync_nodes():
	var is_null = []
	var index = 0
	for s in _sync_nodes:
		if(s == null):
			is_null.append(index)
		index += 1

func clear_all_sync_nodes():
	_sync_count = 1
	_sync_nodes.clear()
	_stored_frames.clear()

func _player_connected(id):
	#nodes need to exist before they are syncronized
	CreationController.sync_creation_new_player(id)
	for s in _sync_nodes:
		if(s == null):
			continue
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

#This function is called on all the clients to send an array
#of inputs up to server for processing
#you don't have to use this but it should make some input handling easier
func send_input_frame(input_data:Dictionary):
	if(NetController.is_net_connected()):
		if(!multiplayer.is_server()):
			var tick = NetController.get_current_tick()
			var data = input_data
			data["tick"] = tick
			rpc_id(1, "_add_input_frame", JSON.stringify(data))

#get the newest entire frame
func get_newest_input_frame(peer_id:int):
	var newest = -1
	var target_frame
	for f in _inputs[peer_id]:
		if(!f.has("tick")):
			continue
		if(f["tick"] > newest):
			newest = f["tick"]
			target_frame = f
	return target_frame

#get a specific input from the newest frame
func get_last_input(peer_id:int, input_tag):
	var f = get_newest_input_frame(peer_id)
	if(f.has(input_tag)):
		return f[input_tag]

#Used for house keeping to delete frames that are not needed
func _pop_oldest_input(peer_id:int):
		var oldest = 999999999999
		var target_frame
		for f in _inputs[peer_id]:
			if(f["tick"] < oldest):
				target_frame = f
				oldest = f["tick"]
		_inputs[peer_id].erase(target_frame)

#rpc methods
#the main and only RPC used to process internal input controls
@rpc("any_peer", "call_remote", "unreliable")
func _add_input_frames(string_data:String):
	if(multiplayer.is_server()):
		var sender_id = multiplayer.get_remote_sender_id()
		var data = JSON.parse_string(string_data)
		if(!_inputs.has(sender_id)):
			_inputs[sender_id] = []
		_inputs[sender_id].append(data)
		if(_inputs[sender_id].size() > _max_input_frames):
			_pop_oldest_input(sender_id)

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
