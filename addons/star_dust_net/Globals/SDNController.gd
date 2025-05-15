extends Node

var _player_ids = []
var _frame_stack = {}


func start_enet_server(port:int) -> int:
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_server(port)
	if(status == OK):
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_peer_connected)
		multiplayer.peer_disconnected.connect(_peer_disconnected)
	return status

func start_enet_client(ip_address:String, port:int)->int:
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_client(ip_address, port)
	if(status == OK):
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(_connected_to_server)
		multiplayer.connection_failed.connect(_connection_failed)
	return status




func send_reliable_packet_to_server(packet:SDNPacket):
	rpc_id(1, "_srpts", packet.serialize)

@rpc("any_peer", "call_remote", "reliable")
func _srpts(packet:SDNPacket):
	var sender_id = multiplayer.get_unique_id()
	if(!_frame_stack.has(sender_id)):
		_frame_stack[sender_id] = []
	_frame_stack.append(packet)


##Takes an array of integers so as to know what clients to send it to
##0 will send to all clients
func send_reliable_packet_to_clients(clients:Array, packet:SDNPacket):
	if(clients.has(0)):
		rpc("_srptc", packet)
	else:
		for i in clients:
			if(i.is_valid_integer()):
				rpc_id(i, "_srptc", packet)

@rpc("authority", "call_remote", "reliable")
func _srptc(packet:PackedByteArray):
	var sender_id = multiplayer.get_unique_id()
	if(!_frame_stack.has(sender_id)):
		_frame_stack[sender_id] = []
	_frame_stack.append(packet)


#server signals
func _peer_connected(id:int):
	_player_ids.append(id)

func _peer_disconnected(id:int):
	_player_ids.erase(id)

#client signals
func _connected_to_server():
	pass

func _connection_failed():
	pass
