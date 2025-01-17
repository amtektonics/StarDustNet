extends SyncData

class_name ChatSyncData

var message:String=""

func _init(sync_id:int, frame_id:int, sender_id:int, message:String):
	super(sync_id, frame_id, sender_id)
	self.message = message
	self.sender_id = sender_id


func serialize():
	return JSON.stringify({"sid":self.sync_id, "fid":self.frame_id, "m":message, "sen":sender_id})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return ChatSyncData.new(data["sid"], data["fid"], data["m"], data["sen"])

