extends SyncData
class_name StressTestSyncData

var blob:String

func _init(sync_id:int, frame_id:int, sender_id:int, blob:String):
	super(sync_id, frame_id, sender_id)

func serialize():
	return JSON.stringify({"sid":self.sync_id, "fid":self.frame_id, "uid":sender_id, "bb":blob})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return StressTestSyncData.new(data["sid"], data["fid"], data["uid"], data["bb"])


static func from_sync_node(node:SyncNode, uid:int, blob:String):
	var frame = StressTestSyncData.new(node.sync_id, NetController.get_current_tick(), uid, blob)
	return frame
