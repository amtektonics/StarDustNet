extends Timer

class_name NamedTimer

signal named_timeout

func _ready():
	timeout.connect(_timeout)


func _timeout():
	emit_signal("named_timeout", get_name())
