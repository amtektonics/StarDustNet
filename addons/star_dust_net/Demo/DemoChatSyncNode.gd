extends SyncNode

class_name ChatSyncNode


signal new_message

func send_message(message):
	if(NetController.is_net_connected()):
		var net_id = multiplayer.get_unique_id()
		var frame = ChatSyncData.new(self.sync_id, NetController.get_current_tick(), message, net_id)
		send_reliable_frame_all_local( frame, true)

func send_server_message(message):
	if(NetController.is_net_connected()):
		if(multiplayer.is_server()):
			var net_id = multiplayer.get_unique_id()
			var frame = ChatSyncData.new(self.sync_id, NetController.get_current_tick(), message, net_id)
			send_reliable_frame_all_local(frame, true)

func _frame_added():
	var frame = get_newest_frame()
	emit_signal("new_message", frame)
	pop_oldest_frame()

func convert_to_object(value):
	return ChatSyncData.deserialize(value)
