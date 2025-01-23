extends VBoxContainer

func _ready():
	NetController.server_started.connect(_server_started)
	NetController.server_disconnected.connect(_server_disconnected)
	

func _on_invite_player_pressed():
	print(NetController.get_steam_friends_lobbies())



func _server_started():
	visible = true

func _server_disconnected():
	visible = false
