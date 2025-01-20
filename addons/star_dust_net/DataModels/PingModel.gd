extends Resource

class_name PingModel

var sender_id:int

var ping_difference:int

func _init(s_id:int, ping:int):
	s_id = sender_id
	ping_difference = ping


func serialize():
	return JSON.stringify({"sid":sender_id, "dif":ping_difference})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return PingModel.new(data["sid"], data["dif"])
