extends CharacterBody3D

class_name SDFPSNetBody3D
##this is a very basic extensable 3d player movement object for First Person Games 
##with basic look movement that works automatically in StarDustNet Multiplayer system

#exports
@export var move_speed:float = 5.0
@export var jump_velocity:float = 4.5
@export var rotation_sensitivity:float = 0.01
@export var tilt_sensitivity:float = 0.01
@export var Camera:Camera3D

#TODO add collision mask information


var movement_sync_node:SDFPSMoveSyncNode

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

##this is where the peer id is stored when the entity is created
##if this is being used for a NPC you can just set the id to 0
var owner_id:int = 0

var _input_vec:Vector2 = Vector2.ZERO

var _input_rot:float = 0.0

var _input_tilt:float = 0.0

var _input_updated:bool = false

var _jump:bool = false


#
var _no_clip:bool = false

var _gravity_enabled: = true


func _ready():
	if(Camera == null):
		assert("The Camera Node needs to be set")
	
	#enable the camera if you you the the local entity
	if(multiplayer.get_unique_id() == owner_id):
		Camera.current = true
	else:
		Camera.current = false
	movement_sync_node = SDFPSMoveSyncNode.new()
	
	add_child(movement_sync_node)
	
	movement_sync_node.new_position.connect(_new_position)

func set_input_move_vector(input_vec:Vector2):
	_input_vec = input_vec

func set_input_rotate(rotation:float):
	_input_rot = rotation

func set_input_tilt(tilt:float):
	_input_tilt = tilt

func set_input_jump(value:bool):
	_jump = value
	
func _physics_process(delta: float) -> void:
	var input_dir:Vector2 = Vector2.ZERO
	var input_rot:float = 0.0
	var input_tilt:float = 0.0
	var jump:bool = false
	var primary_input:bool = false
	var secondary_input:bool = false
	var use_input:bool = false
	
	var primary_input_edge:bool = false
	var secondary_input_edge:bool = false
	var use_input_edge:bool = false
	
	if(multiplayer.get_unique_id() == owner_id):
		input_dir = _input_vec
		input_rot = _input_rot
		input_tilt = _input_tilt
		jump = _jump
		
		var input_data = {
			"px":input_dir.x, 
			"py":input_dir.y, 
			"j":jump, 
			"mx":input_rot, 
			"my":input_tilt,
			"pa":primary_input,
			"sa":secondary_input,
			"ua":use_input}
		
		FrameSyncController.send_input_frame(input_data)
	
	if(multiplayer.is_server()):
		var px =  FrameSyncController.get_last_input(owner_id, "px")
		var py =  FrameSyncController.get_last_input(owner_id, "py")
		var mx = FrameSyncController.get_last_input(owner_id, "mx")
		var my = FrameSyncController.get_last_input(owner_id, "my")
		var j = FrameSyncController.get_last_input(owner_id, "j")
		var pa = FrameSyncController.get_last_input(owner_id, "pa")
		var sa = FrameSyncController.get_last_input(owner_id, "sa")
		var ua = FrameSyncController.get_last_input(owner_id, "ua")
		if(px != null && py != null && mx != null && my != null && j != null && pa != null && sa != null && ua != null):
			input_dir = Vector2(px, py)
			input_rot = mx
			input_tilt = my
			
			if (primary_input == false && pa):
				primary_input_edge = true
			primary_input = pa
			
			if (secondary_input == false && sa):
				secondary_input_edge = true
			secondary_input = sa
			
			if(use_input == false && use_input):
				use_input_edge = true
			use_input = ua
			jump = j
	
	
	if(multiplayer.get_unique_id() == owner_id || multiplayer.is_server()):
		if (!is_on_floor() && _gravity_enabled):
			velocity.y -= gravity * delta
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if(direction):
			if(_no_clip):
				var rotation_axis = Vector3(direction.x, 0, direction.z).normalized()
				direction = direction.rotated(rotation_axis,Camera.rotation.x)
				velocity.y = direction.y * move_speed * -sign(input_dir.y)
			
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
			
		if(jump):
			if(_no_clip):
				velocity.y = move_speed
			elif (is_on_floor()):
					velocity.y = jump_velocity 
		
		rotate_y(input_rot * delta * rotation_sensitivity)
		
		Camera.rotate_x(input_tilt * delta * tilt_sensitivity)
		Camera.rotation.x = clamp(Camera.rotation.x, -PI/2, PI/2)
		
		if(primary_input_edge):
			_primary_button_just_pressed()
		
		if(secondary_input_edge):
			_secondary_button_just_pressed()
		
		if(use_input_edge):
			_use_button_just_pressed()
	
	move_and_slide()
	
	if(multiplayer.is_server()):
		var frame = SDFPSMoveSyncData.from_sync_node(movement_sync_node,multiplayer.get_unique_id(), get_global_position(), get_global_rotation().y, Camera.get_global_rotation().x)
		movement_sync_node.send_unreliable_frame_all(frame)

var last_frame:SDFPSMoveSyncData = null
func _new_position(frame:SDFPSMoveSyncData):
	var new_pos = frame.position
	var new_rot = frame.rotation
	var new_tilt = frame.tilt
	var best_frame = null
	var ping = NetController.get_ping_average(owner_id)
	if(last_frame != null):
		var tick_diff = NetController.get_current_tick() - frame.frame_id
		new_pos = StarDustUtil.compensate_lag_Vector3(last_frame.position, frame.position, tick_diff)
		new_rot = StarDustUtil.compensate_lag_angle(last_frame.rotation, frame.rotation, tick_diff)
		new_tilt = StarDustUtil.compensate_lag_angle(last_frame.tilt, frame.tilt, tick_diff)
	
	set_position(new_pos)
	rotation.y = new_rot
	Camera.rotation.x = new_tilt
	last_frame = frame
	
#overridable actions
func _primary_button_just_pressed():
	pass

func _secondary_button_just_pressed():
	pass

func _use_button_just_pressed():
	pass

#code for handling the creation node itself
#------------------------------------------
var _res_id = 0

#Pass a json object
func handle_args(args:String):
	var data = JSON.parse_string(args)
	if(data.has("oid")):
		owner_id = data["oid"]
		set_name(str(int(data["oid"])))
	if(data.has("px") && data.has("py") && data.has("pz")):
		set_position(Vector3(data["px"], data["py"], data["pz"]))
	if(data.has("r")):
		rotation.y = data["r"]
	if(data.has("tt")):
		Camera.rotation.x = data["tt"]

func get_updated_args()->String:
	var data = {
		"oid":owner_id,
		"px":get_global_position().x,
		"py":get_global_position().y,
		"pz":get_global_position().z,
		"r":get_global_rotation().y,
		"tt":Camera.get_global_rotation().x
	}
	return JSON.stringify(data)

static func create_args(owner_id:int, position:Vector3, rotation:float, tilt:float):
	var data = {
		"oid":owner_id,
		"px":position.x,
		"py":position.y,
		"pz":position.z,
		"r":rotation,
		"tt":tilt
	}
	return JSON.stringify(data)

func set_res_id(value:int):
	_res_id = value

func get_res_id():
	return _res_id
	
func remove_from_net():
	FrameSyncController.remove_sync_node(movement_sync_node.sync_id)
	CreationController.remove_net_node(_res_id)
