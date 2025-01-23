extends VBoxContainer

func _ready():
	NetController.server_started.connect(_server_started)

func _on_host_game_pressed():
	$HostGame.disabled = true
	NetController.start_steam_lobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 6)
	

func _server_started():
	visible = false
