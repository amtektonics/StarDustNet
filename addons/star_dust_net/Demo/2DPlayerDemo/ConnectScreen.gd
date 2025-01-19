extends Control

func _ready():
	NetController.connected_to_server.connect(_connected_to_server)
	NetController.server_disconnected.connect(_server_disconnected)
	NetController.failed_to_connect.connect(_failed_to_connect)

func _on_host_pressed():
	if($VBox/Port.text != ""):
		NetController.start_enet_server(int($VBox/Port.text))
		_disable_input()
		visible = false


func _on_join_pressed():
		if($VBox/Port.text != "" && $VBox/Address.text != ""):
			NetController.start_enet_client($VBox/Address.text, int($VBox/Port.text))
			_disable_input()


func _disable_input():
	$VBox/Address.editable = false
	$VBox/Port.editable = false
	$VBox/Host.disabled = true
	$VBox/Join.disabled = true

func _enable_input():
	$VBox/Address.editable = true
	$VBox/Port.editable = true
	$VBox/Host.disabled = false
	$VBox/Join.disabled = false

func _connected_to_server():
		visible = false

func _failed_to_connect():
	visible = true
	_enable_input()
	NetController.close_network_peer()

func _server_disconnected():
	_enable_input()
	visible = true
	NetController.close_network_peer()
