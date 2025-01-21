extends Node

class_name SyncNode

#used to identify the sync node across connections
#the server will pick the id and assign it
var sync_id = 0

var _res_id = 0

#a generic stack of data frames sent to this peer
var _sync_stack:Array[SyncData] = []


func _ready():
	#this will auto register the Sync node when it first gets added
	#to the Scene or when the server first starts up but only on the server side
	if(NetController.is_net_connected()):
		if(multiplayer.is_server()):
			FrameSyncController.register_sync_node(self)
	else:
		NetController.server_started.connect(_server_started)

#add a frame of data as a json string
#it will be converted to the correct object on the fly and created
func add_frame_data(data:String):
	var frame = convert_to_object(data)
	_sync_stack.append(frame)
	_frame_added()

#override this node if it's also a creation node
#but don't forget to remove the sync part first
func remove_from_net():
	FrameSyncController.remove_sync_node(sync_id)

#data transmision functions
#store referses to if we want the frame to be stored so it can be sent
#to new clients that connect after sending it
func send_reliable_frame(peer_id:int, data:SyncData, store=false):
	FrameSyncController.rpc_id(peer_id, "send_reliable_frame", data.serialize(), store)

func send_unreliable_frame(peer_id:int, data:SyncData, store=false):
	FrameSyncController.rpc_id(peer_id, "send_unreliable_frame", data.serialize(), store)

func send_reliable_frame_all(data:SyncData, store=false):
	FrameSyncController.rpc("send_reliable_frame", data.serialize(), store)

func send_unreliable_frame_all(data:SyncData, store=false):
	FrameSyncController.rpc("send_unreliable_frame", data.serialize(), store)

func send_reliable_frame_all_local(data:SyncData, store=false):
	FrameSyncController.rpc("send_reliable_frame_local", data.serialize(),store)

func send_unreliable_frame_all_local(data:SyncData, store=false):
	FrameSyncController.rpc("send_unreliable_frame_local", data.serialize(), store)

#using the tick frame find the newest frame we have on the stack
func get_newest_frame():
	var big_frame = -1
	var target_frame:SyncData
	for s in _sync_stack:
		if(s.frame_id > big_frame):
			target_frame = s
			big_frame = s.frame_id
	return target_frame

func get_second_newest_frame():
	var big_frame = -1
	var target_frame:SyncData
	var second:SyncData
	for s:SyncData in _sync_stack:
		if(s.frame_id > big_frame):
			second = target_frame
			target_frame = s
			big_frame = s.frame_id
	return second

#remove the oldest frame fron the stack since it will be of the least value
func pop_oldest_frame():
	var small_frame = 9223372036854775807
	var target_frame:SyncData
	for s:SyncData in _sync_stack:
		if(s.frame_id < small_frame):
			target_frame = s
			small_frame = s.frame_id
	_sync_stack.erase(target_frame)

func get_frame_count():
	return _sync_stack.size()

func delete_newest_frame():
	var big_frame = 0
	var target_frame:SyncData
	for s:SyncData in _sync_stack:
		if(s.frame_id > big_frame):
			target_frame = s
			big_frame = s.frame_id
	_sync_stack.erase(target_frame)

func get_all_frames():
	return _sync_stack

#this isn't really needed but it makes it easier if
#the sync node is the only thing getting intalized
func set_res_id(res_id:int):
	_res_id = res_id

func get_res_id():
	return _res_id

#overides
#this override is ment for converting a json string value into a Sync Object
func convert_to_object(value:String):
	return SyncData.deserialize(value)


func _frame_added():
	pass

func _server_started():
	FrameSyncController.register_sync_node(self)
