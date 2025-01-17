extends SyncNode

class_name POS2DSyncNode

var position = Vector2()

signal position_updated

func send_position_update(pos:Vector2):
	var uid = multiplayer.get_unique_id()
	var frame = Pos2DSyncData.from_sync_node(self, uid, pos)
	send_unreliable_frame_all(frame)

func _frame_added():
	var current_frame = get_newest_frame()
	var last_frame = get_second_newest_frame()
	if(current_frame != null && last_frame != null):
		if(current_frame.sender_id == 1 && last_frame.sender_id == 1):
			var frame_diff = current_frame.frame_id - last_frame.frame_id
			position = last_frame.position.lerp(current_frame.position, frame_diff / 16)
			emit_signal("position_updated", position)
	
	if(get_frame_count() > 30):
		pop_oldest_frame()

func convert_to_object(value):
	return Pos2DSyncData.deserialize(value)

