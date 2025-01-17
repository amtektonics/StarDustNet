extends Node

#player data
var _connected_players:Array[NetPlayerModel] = []

#an array of pings per client for getting lag
var _ping_history = {}

#tick is used for syncing frames
var _ticks = 0

#server tick rate is the physiscs tick rate
#of the server
var _server_tickrate

var _is_connected = false

var _client_setup_grace_period = 2.0

signal player_connected

signal player_disconnected

signal connected_to_server

signal failed_to_connect

signal server_disconnected

signal server_started

signal peer_closed

#straight forward peer server spinup
#the name system will be replaced with Steam names in the future
func start_enet_server(port:int):
	var _multiplayer_peer = ENetMultiplayerPeer.new()
	var status = _multiplayer_peer.create_server(port)
	if(status == OK):
		multiplayer.multiplayer_peer = _multiplayer_peer
		_register_server_signals()
		_is_connected = true
		_connected_players.append(NetPlayerModel.new("", 1))
		emit_signal("server_started")
	return status

#straight forward peer client spinup
func start_enet_client(ip_address:String, port:int):
	var _multiplayer_peer = ENetMultiplayerPeer.new()
	var status = _multiplayer_peer.create_client(ip_address, port)
	if(status == OK):
		multiplayer.multiplayer_peer = _multiplayer_peer
		_register_client_signals()
		_is_connected = true
	return status

#close for both server and client
func close_network_peer():
	#clear this data first we won't need it anymore
	_ping_history.clear()
	_connected_players.clear()
	emit_signal("peer_closed")
	if(self.is_net_connected()):
		if(multiplayer.is_server()):
			_disconnect_server_signals()
		else:
			_disconnect_client_signals()
		_is_connected = false
		multiplayer.multiplayer_peer.close()

#does a snapshot of pings to get an average over time
func get_ping_average(peer_id:int):
	if(_ping_history.has(peer_id)):
		var count = 0
		var ping_sum = 0
		for p:PingModel in _ping_history[peer_id]:
			ping_sum = p.ping_difference
			count += 1
		
		return ping_sum / count
	else:
		return -1

func get_all_player_data():
	return _connected_players

func get_current_tick():
	return _ticks

func get_player_name(peer_id:int):
	for p:NetPlayerModel in _connected_players:
		if(p.peer_id == peer_id):
			return p.player_name
	return null

func get_player_peer_id(player_name:String):
	for p:NetPlayerModel in _connected_players:
		if(p.player_name == player_name):
			return p.peer_id
	return null

func is_net_connected():
	return _is_connected

func _physics_process(delta):
	if(_is_connected):
		_ticks += 1
		#this is currently set to the physics tick * an interval value
		#this will ping the clients every second with an interval value of 0
		if(multiplayer.is_server()):
			if(_ticks % (Engine.get_physics_ticks_per_second() * 3) == 0):
				#send out new pings every to get the current lag
				for p in _connected_players:
					if(p.peer_id == 1):
						continue
					_ping(p.peer_id)
				#sync the servers history with all the clients
				rpc("_sync_ping_history", _ping_history)

#private internal functions
func _register_server_signals():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _disconnect_server_signals():
	multiplayer.peer_connected.disconnect(_peer_connected)
	multiplayer.peer_disconnected.disconnect(_peer_disconnected)

func _register_client_signals():
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _disconnect_client_signals():
	multiplayer.connected_to_server.disconnect(_connected_to_server)
	multiplayer.connection_failed.disconnect(_connection_failed)
	multiplayer.server_disconnected.disconnect(_server_disconnected)

func _serialize_players():
	var players = []
	for p:NetPlayerModel in _connected_players:
		players.append(p.serialize())
	
	return players

func _ping(peer_id:int):
	rpc_id(peer_id, "_pong", Time.get_ticks_msec())

@rpc("any_peer", "call_remote", "reliable")
func _pong(time:int):
	var sender = multiplayer.get_remote_sender_id()
	if(multiplayer.is_server()):
		if(!_ping_history.has(sender)):
			_ping_history[sender] = []
		
		_ping_history[sender].append(PingModel.new(sender, Time.get_ticks_msec() - time))
		if(_ping_history[sender].size() > 10):
			_ping_history[sender].pop_front()
	else:
		#send it back!
		rpc_id(sender, "_pong", time)

#sent by the client on connection to the server
@rpc("any_peer", "call_local", "reliable")
func _register_player_name(player_name:String):
	if(multiplayer.is_server()):
		var id = multiplayer.get_remote_sender_id()
		for p:NetPlayerModel in _connected_players:
			if(p.peer_id == id):
				p.player_name = player_name
				break
		rpc("_sync_players", _serialize_players())

#on every update the server will provide new player data to the clients
@rpc("authority", "call_remote", "reliable")
func _sync_players(player_data_array:Array):
	var player_data:Array[NetPlayerModel] = []
	#deserialize the data
	for p:String in player_data_array:
		var np = NetPlayerModel.deserialize(p)
		player_data.append(np)
	
	#Loop throught to find any disconnections
	for p:NetPlayerModel in _connected_players:
		if(p.peer_id == multiplayer.get_unique_id()):
			continue
		var _has_player = false
		for p2:NetPlayerModel in player_data:
			if(p.peer_id == p2.peer_id):
				_has_player = true
				break
		if(!_has_player):
			emit_signal("player_disconnected", p.peer_id)
	
	#Loop through to find any connections
	for p:NetPlayerModel in player_data:
		if(p.peer_id == multiplayer.get_unique_id()):
			continue
		var _has_player = false
		for p2:NetPlayerModel in _connected_players:
			if(p.peer_id == p2.peer_id):
				_has_player = true
				break
		
		if(!_has_player):
			emit_signal("player_connected", p.peer_id)
	
	_connected_players = player_data

@rpc("authority", "call_remote", "reliable")
func _sync_ticks(tickrate, ticks):
	if(!multiplayer.is_server()):
		Engine.set_physics_ticks_per_second(tickrate)
		_ticks = ticks

@rpc("authority", "call_remote", "reliable")
func _sync_ping_history(ping_history):
	if(!multiplayer.is_server()):
		_ping_history = ping_history

func _remove_peer(peer_id:int):
	#removes the player from the player list if the leave the server
	for p:NetPlayerModel in _connected_players:
		if(p.peer_id == peer_id):
			_connected_players.erase(p)
			break

func _peer_connected(id):
	_connected_players.append(NetPlayerModel.new("", id))
	#tell all the clients what the new player list is
	rpc("_sync_players", _serialize_players())
	#sync the new player with the server time and tickrate
	rpc_id(id, "_sync_ticks", Engine.get_physics_ticks_per_second(), _ticks)
	#this is called this way for the servers 
	#then called seperately durring the sync on the clients 
	emit_signal("player_connected", id)

func _peer_disconnected(id):
	_remove_peer(id)
	_sync_players(_serialize_players())
	#this is called this way for the servers 
	#then called seperately durring the sync on the clients
	emit_signal("player_disconnected", id)

func _connected_to_server():
	rpc_id(1, "_register_player_name", "Bob")
	#_sync_players(_serialize_players())
	emit_signal("connected_to_server")

func _connection_failed():
	emit_signal("failed_to_connect")

func _server_disconnected():
	_is_connected = false
	emit_signal("server_disconnected")
