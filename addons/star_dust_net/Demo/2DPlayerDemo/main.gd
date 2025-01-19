extends Node


func _ready():
	NetController.player_connected.connect(_player_connected)
	NetController.server_started.connect(_server_started)


func _process(delta):
	if(NetController.is_net_connected()):
		pass

func _player_connected(id):
	var args = JSON.stringify({"name": str(id)})
	CreationController.create_net_node("res://addons/star_dust_net/CreationNodes/Input2DClientNode.tscn", str(get_path()) + "/Inputs", args)
	var x = randi_range(1, 100)
	var y = randi_range(1, 100)
	var p_args = JSON.stringify({"posx":x, "posy":y, "oid":id})
	CreationController.create_net_node("res://addons/star_dust_net/CreationNodes/player.tscn", str(get_path()) + "/Players", p_args)
	
func _server_started():
	var args = JSON.stringify({"name": str(1)})
	CreationController.create_net_node("res://addons/star_dust_net/CreationNodes/Input2DClientNode.tscn", str(get_path()) + "/Inputs", args)
	
	var x = randi_range(1, 100)
	var y = randi_range(1, 100)
	var p_args = JSON.stringify({"posx":x, "posy":y, "oid":1})
	CreationController.create_net_node("res://addons/star_dust_net/CreationNodes/player.tscn", str(get_path()) + "/Players", p_args)
