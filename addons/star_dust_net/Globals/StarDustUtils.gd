extends Node

#compensate for lag
#=========================================================================================
func compensate_lag_Vector2(old_position:Vector2, new_position:Vector2, tick_diff:float)-> Vector2:
	if(tick_diff != 0):
		return old_position.lerp(new_position, .01 / tick_diff)
	else:
		return new_position

func compensate_lag_Vector3(old_position:Vector3, new_position:Vector3, tick_diff:float)-> Vector3:
	if(tick_diff != 0):
		return old_position.lerp(new_position, .01 / tick_diff)
	else:
		return new_position

func compensate_lag_float(old_float:float, new_float:float, tick_diff:float)-> float:
	if(tick_diff != 0):
		return lerp(old_float, new_float, .01 / tick_diff)
	else:
		return new_float

func compensate_lag_angle(old_float:float, new_float:float, tick_diff:float)-> float:
	if(tick_diff != 0):
		return lerp_angle(old_float, new_float, .01 / tick_diff)
	else:
		return new_float
#=================================================================================
