extends SyncData
class_name SDFPSMoveSyncData

var position = Vector3()
var rotation = 0.0
var tilt = 0.0

func _init(sync_id:int, frame_id:int, sender_id:int, position:Vector3, rotation:float, tilt:float):
	super(sync_id, frame_id, sender_id)
	self.position = position
	self.rotation = rotation
	self.tilt = tilt

func serialize():
	return JSON.stringify({"sid":self.sync_id, "fid":self.frame_id, "uid":sender_id, "px":position.x, "py":position.y, "pz":position.z, "r":rotation, "t":tilt})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return SDFPSMoveSyncData.new(data["sid"], data["fid"], data["uid"], Vector3(data["px"],data["py"],data["pz"]),data["r"], data["t"])


static func from_sync_node(node:SyncNode, uid:int, position:Vector3, rotation:float, tilt:float):
	var frame = SDFPSMoveSyncData.new(node.sync_id, NetController.get_current_tick(), uid, position, rotation, tilt)
	return frame
