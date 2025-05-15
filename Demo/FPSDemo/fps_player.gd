extends SDFPSNetBody3D

func _ready():
	super()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	super(delta)
	var move = Input.get_vector("move_left","move_right","move_up","move_down")
	var mouse = Input.get_last_mouse_velocity()
	
	set_input_move_vector(move)
	set_input_rotate(-mouse.x)
	
	set_input_tilt(-mouse.y)
