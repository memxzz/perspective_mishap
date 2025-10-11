extends Node3D
var plr
@export var fov:float
@export var size:float
@export var lock:bool
@export var lockVelocity:float
@export var onlyOneWorldMode:bool
@export var desactivateOnExit:bool
@export_range(1,2) var worldMode:int
@onready var camPlace = $cameraPlace
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return

func _on_area_3d_body_entered(body: Node3D) -> void:
	plr = GlobalVars.vars.plr
	if onlyOneWorldMode == true and GlobalVars.vars.worldMode != worldMode:return
	if plr == null:return
	if not GlobalVars.vars.actualScene:return
	if body is CharacterBody3D:
		plr.camera.locked = lock
		plr.camera.lockFov = fov
		plr.camera.lockSize = size
		plr.camera.lockVector.position = camPlace.global_position
		plr.camera.lockVector.rotation = camPlace.global_rotation
		plr.camera.lockVelocity = lockVelocity

func _on_area_3d_body_exited(body: Node3D) -> void:
	plr = GlobalVars.vars.plr
	print("hi")
	if plr == null:return
	if body is CharacterBody3D:
		plr.camera.locked = false
