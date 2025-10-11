extends Node3D
var plr
@export var hitbox: Node3D
@export var text: Node3D
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	var distance = text.distance
	var dist = clamp(plr.global_position.distance_to(hitbox.global_position),0,distance)
	var val = 1-(dist/distance)
	if val <= 0:
		text.visible = false
		text.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		text.visible = true
		text.process_mode = Node.PROCESS_MODE_INHERIT
