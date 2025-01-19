extends SyncNode

class_name Input2DClientSyncNode

var move_dir = Vector2()

func handle_args(args:String):
	var data = JSON.parse_string(args)
	if(data.has("name")):
		set_name(data["name"])

func get_updated_args():
	return JSON.stringify({"name":get_name()})

func send_move_update(move_update:Vector2):
	if(!multiplayer.is_server()):
		var uid = multiplayer.get_unique_id()
		var frame = Input2DClientSyncData.from_sync_node(self, uid, move_update)
		send_unreliable_frame(1, frame)

func _frame_added():
	if(multiplayer.is_server()):
		var frame:Input2DClientSyncData = get_newest_frame()
		if(frame != null):
			if(frame.sender_id == int(str(get_name()))):
				#normalize the vector to make sure nothing strange is going on
				if(!frame.move_dir.is_normalized()):
					move_dir = frame.move_dir.normalized()
				else:
					move_dir = frame.move_dir
			else:
				#someone is sending packets they shouldn't
				print("Inputs being manupulated by player " + str(frame.sender_id) +" to " + get_name())
				delete_newest_frame()
		
	if(get_frame_count() > 10):
		pop_oldest_frame()

func convert_to_object(value):
	return Input2DClientSyncData.deserialize(value)
