extends Node

func _ready():
	NetController.connected_to_server.connect(_connected_to_server)


func _connected_to_server():
	$Control.visible = false

func _on_punch_pressed():
	print(NetController.create_stun_server_room("45.33.127.132", 5000))
	print(NetController.start_enet_server(5000))

func _on_connect_pressed():
	var result = NetController.get_room_info("45.33.127.132", 5000, $Control/ConnectionCode.text)
	if(result != "no_room"):
		var data = result.split(":")
		
		print(NetController.start_enet_client(data[3], int(data[4])))
