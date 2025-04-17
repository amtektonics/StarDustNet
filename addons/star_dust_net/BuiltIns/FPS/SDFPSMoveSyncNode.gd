extends SyncNode
class_name SDFPSMoveSyncNode


signal new_position

func _frame_added():
	var frame = get_newest_frame()
	emit_signal("new_position", frame)
	
	if(get_frame_count() > 4):
		pop_oldest_frame()


func convert_to_object(value):
	return SDFPSMoveSyncData.deserialize(value)
