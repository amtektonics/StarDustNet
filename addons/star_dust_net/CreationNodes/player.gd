extends CharacterBody2D

var _owner_id = 0
var _res_id = 0

var move_dir = Vector2()

func handle_args(args:String):
	var data = JSON.parse_string(args)
	if(data.has("posx") && data.has("posy")):
		set_position(Vector2(data["posx"], data["posy"]))
	if(data.has("oid")):
		_owner_id = data["oid"]

func _ready():
	if(_owner_id == multiplayer.get_unique_id()):
		$Camera2D.enabled = true

func _physics_process(delta):
	if(NetController.is_net_connected()):
		var my_id = multiplayer.get_unique_id()
		move_dir = Vector2()
		velocity = Vector2()
		if(_owner_id == my_id):
			if(Input.is_action_pressed("move_up")):
				move_dir.y -= 1
			if(Input.is_action_pressed("move_down")):
				move_dir.y += 1
			if(Input.is_action_pressed("move_left")):
				move_dir.x -= 1
			if(Input.is_action_pressed("move_right")):
				move_dir.x += 1
			get_node("/root/main/Inputs/" + str(my_id)).send_move_update(move_dir)
			
		if(multiplayer.is_server()):
			if(_owner_id != 1):
				var n = get_node("/root/main/Inputs/" + str(_owner_id))
				if(n != null):
					move_dir = n.move_dir
					
			velocity += move_dir * 1000 * 5 * delta
			move_and_slide()
			$POS2DSyncNode.send_position_update(get_position())


func set_res_id(res_id:int):
	_res_id = res_id


func _on_pos_2d_sync_node_position_updated(pos:Vector2):
	set_position(pos)
