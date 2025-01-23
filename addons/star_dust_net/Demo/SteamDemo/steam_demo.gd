extends Node

func _ready():
	var response = Steam.steamInitEx(true, 480)
