extends Node

func _ready():
	NetController.player_connected.connect(_player_connected)
	NetController.server_started.connect(_server_started)


func _player_connected(id:int):
	$ConnectedMenu.visible = true

func _server_started():
	$ConnectedMenu.visible = true
