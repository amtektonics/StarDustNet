extends Node

func _ready():
	NetController.player_connected.connect(_player_connected)
	NetController.server_started.connect(_server_started)


func _player_connected(id:int):
	var path = str($World.get_path())
	var args = SDFPSNetBody3D.create_args(id, Vector3(0, 10, 0), 0, 0)
	CreationController.create_net_node("res://Demo/FPSDemo/fpsPlayer.tscn", path, args)

func _server_started():
	var path = str($World.get_path())
	var args = SDFPSNetBody3D.create_args(1, Vector3(0, 10, 0), 0, 0)
	CreationController.create_net_node("res://Demo/FPSDemo/fpsPlayer.tscn", path, args)
