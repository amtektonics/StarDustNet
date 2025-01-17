extends Resource

class_name SyncData

var sync_id:int
var frame_id:int
var sender_id:int

func _init(sync_id:int, frame_id:int, sender_id:int):
	self.sync_id = sync_id
	self.frame_id = frame_id
	self.sender_id = sender_id

func serialize():
	return JSON.stringify({"sid":self.sync_id, "fid":self.frame_id, "uid":sender_id})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return SyncData.new(data["sid"], data["fid"], data["uid"])
