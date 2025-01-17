extends SyncData
class_name Input2DClientSyncData

var move_dir = Vector2()

func _init(sync_id:int, frame_id:int, sender_id:int, move_dir:Vector2):
	super(sync_id, frame_id, sender_id)
	self.move_dir = move_dir

static func from_sync_node(node:SyncNode, uid:int, move_dir:Vector2):
	var frame = Input2DClientSyncData.new(node.sync_id, NetController.get_current_tick(), uid, move_dir)
	return frame

func serialize():
	return JSON.stringify({"sid":self.sync_id, "fid":self.frame_id, "uid":sender_id, "mdx":move_dir.x, "mdy":move_dir.y})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return Input2DClientSyncData.new(data["sid"], data["fid"], data["uid"], Vector2(data["mdx"], data["mdy"]))
