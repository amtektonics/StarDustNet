extends Resource

class_name NetPlayerModel

var peer_id:int

var data = {}


func _init(peer_id:int, data:Dictionary):
	self.peer_id = peer_id
	self.data = data


func set_data(key, value):
	data[key] = value

func get_data(key):
	if(data.has(key)):
		return data[key]
	return null

func serialize()-> String:
	return JSON.stringify({"pid":self.peer_id, "d":JSON.stringify(self.data)})


static func deserialize(value:String)->NetPlayerModel:
	var data = JSON.parse_string(value)
	return NetPlayerModel.new(data["pid"], JSON.parse_string(data["d"]))
