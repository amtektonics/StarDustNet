extends SyncNode
class_name StressTestSyncNode
@export var server_byte_count:int = 1000
@export var client_byte_count:int = 1000
@export var send_from_server:bool = false
@export var send_from_client:bool = false

var _text = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmonpqrstuvwxyz0123456789"


func _physics_process(delta: float) -> void:
	if(NetController.is_net_connected()):
		if(send_from_server && multiplayer.is_server()):
			var blob = ""
			for i in range(server_byte_count):
				blob += _text[randi_range(0, _text.length()-1)]
			var data = StressTestSyncData.from_sync_node(self, multiplayer.get_unique_id(), blob)
			send_reliable_frame_all(data)
		
		if(send_from_client && !multiplayer.is_server()):
			var blob = ""
			for i in range(client_byte_count):
				blob += _text[randi_range(0, _text.length()-1)]
			var data = StressTestSyncData.from_sync_node(self, multiplayer.get_unique_id(), blob)
			send_reliable_frame_all(data)


#this function is called when a new 
#function is sent over to this sync node
func _frame_added():
	var frame = get_newest_frame()


#this function is built in to
#deserialize the frames to the correct data type
func convert_to_object(value):
	return StressTestSyncData.deserialize(value)
