extends CanvasLayer

@export var address:LineEdit
@export var port:LineEdit

func _ready():
	NetController.connected_to_server.connect(_connected_to_server)
	NetController.server_started.connect(_server_started)
	


func _on_host_pressed() -> void:
	if(port.text != ""):
		NetController.start_enet_server(int(port.text))


func _on_join_pressed() -> void:
	if(address.text != "" && port.text != ""):
		NetController.start_enet_client(address.text, int(port.text))

func _connected_to_server():
	visible = false

func _server_started():
	visible = false
