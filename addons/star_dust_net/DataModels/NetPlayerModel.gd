extends Resource

class_name NetPlayerModel

var player_name:String

var peer_id:int


func _init(player_name:String, peer_id:int):
	self.player_name = player_name
	self.peer_id = peer_id


func serialize()-> String:
	return JSON.stringify({"player_name":self.player_name, "peer_id":self.peer_id})


static func deserialize(value:String)->NetPlayerModel:
	var data = JSON.parse_string(value)
	return NetPlayerModel.new(data["player_name"], data["peer_id"])
