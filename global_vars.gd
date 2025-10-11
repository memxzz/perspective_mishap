extends Node


# Called when the node enters the scene tree for the first time.
var vars = {
	worldMode = 1, #1 = 2d #2 = 3d
	plr = null,
	actualScene = null,
	time = 0
}
func _process(delta: float) -> void:
	vars.time += delta
