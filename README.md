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

## Plugin Tools
When the plugin is enabled it will created a new menu on the left side bar. The bar gives you the ability to generate gdscripts you will need with pre generated field.


----

## Planned Features for the future
* Rollback example Demo
* Steam VPN lobby integration as an option using Godot Steam add-on
* Stun and Turn support for mobile applications  (maybe web at some point but not anytime soon)
* Some ready to go out of the box nodes that makes sense are documented and just work to lower the bar to entry


  ## Please provide feedback and any recommendations to improve the library
