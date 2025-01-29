# Star Dust Net
### Version Support -- Godot 4.2 
### Alpha, a lot of it can change with updates
This addons goal is to simplify the creation of multiplayer peer to peer server authoritative games.\
It would be considered an unnecessary complication for basic peer-to-peer games, but if you want better control of data packets on the back and front end, hopefully this will help.


# Core Concepts
There are 3 autoload nodes that can be used to interact with the different parts of the library
* NetController
* FrameSyncController
* CreationController

## NetController
This is the heart of Star Dust Net. it is what you will call when you want to start and stop the client/server application.

## FrameSyncController
This is the comunication core. It acts as a throughput for ``SyncData`` to be able to transfer between two ``SyncNodes``.\


#### SyncData
This is a generic object type that expects to be overwritten but provides a uniform data type to be able to navigate through the ``FrameSyncController``.\
It also exposes a serialize and deserialize function to be able to transmit the data over the network.\



#### SyncNode
This is a generic destination object that takes in ``SyncData`` it is also meant to be overwritten for each specific implementation.\
This ``SyncNode`` is also where frames are stored and handled they are meant to surface data that allows the nodes to be changed\
``SyncNode`` automagically checks in with the ``FrameSyncController`` and the server assigns them a unique id for later referencing.

## CreationController
This is used to instantiate ``SyncNode`` a call can be made to the ``CreationController`` to ask it to spawn a scene that will get automatically send to all clients.\
If someone late joins, the ``CreationController`` remembers and will populate the new client with all the ``SyncNode``

----

## Chat Example

Below are the only two classes you would need to build (excluding normal game stuff) to be able to make a basic chat system


### ChatSyncData.gd
This just acts as a data layer to be able to navigate through the ``FrameSyncController``\
The first 3 values are required, but after that, you can add any data you want that can be encoded into JSON
``` gdscript
extends SyncData

class_name ChatSyncData

var message:String=""

func _init(sync_id:int, frame_id:int, sender_id:int, message:String):
	super(sync_id, frame_id, sender_id)
	self.message = message
	self.sender_id = sender_id


#the letters or numbers for these packets don't matter they just need to match between the two functions
func serialize():
	return JSON.stringify({"sid":self.sync_id, "fid":self.frame_id, "m":message, "sen":sender_id})

static func deserialize(value:String):
	var data = JSON.parse_string(value)
	return ChatSyncData.new(data["sid"], data["fid"], data["m"], data["sen"])

```

### ChatSynNode.gd
``` gdscript
extends SyncNode

class_name ChatSyncNode


signal new_message

func send_message(message):
	if(NetController.is_net_connected()):
		var net_id = multiplayer.get_unique_id()
		var frame = ChatSyncData.new(self.sync_id, NetController.get_current_tick(), message, net_id)
		send_reliable_frame_all_local( frame, true)

func send_server_message(message):
	if(NetController.is_net_connected()):
		if(multiplayer.is_server()):
			var net_id = multiplayer.get_unique_id()
			var frame = ChatSyncData.new(self.sync_id, NetController.get_current_tick(), message, net_id)
			send_reliable_frame_all_local(frame, true)

#The two functions below are overrides from SyncNode
#_frame_added is built in and fires off when the node gets a new frame
func _frame_added():
	var frame = get_newest_frame()
	emit_signal("new_message", frame)
	pop_oldest_frame()

#This is so it deserializes into the correct Data Type
func convert_to_object(value):
	return ChatSyncData.deserialize(value)

```

## Planned Features for the future
* Rollback example Demo
* Steam VPN lobby integration as an option using Godot Steam add-on
* Stun and Turn support for mobile applications  (maybe web at some point but not anytime soon)
* Some ready to go out of the box nodes that makes sense are documented and just work to lower the bar to entry


  ## Please provide feedback and any recommendations to improve the library
