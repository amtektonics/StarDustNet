extends SyncData

class_name  Pos2DSyncData

var position = Vector2()

func _init(sync_id:int, frame_id:int, sender_id:int, position:Vector2):
	super(sync_id, frame_id, sender_id)
	self.position = position

static func from_sync_node(node:SyncNode, uid:int, position:Vector2):
	var frame = Pos2DSyncData.new(node.sync_id, NetController.get_current_tick(), uid, position)
	return frame

func serialize():
	return JSON.stringify({"sid":sync_id, "fid":frame_id, "uid":sender_id, "px":position.x, "py":position.y})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return Pos2DSyncData.new(data["sid"], data["fid"], data["uid"], Vector2(data["px"], data["py"]))
