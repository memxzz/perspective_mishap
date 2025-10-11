extends Camera3D
@export_range(0.0, 1.0) var value: float = 0.0 
@export var max_multiplier: float = 200.0
@export var base_position: Vector3 = Vector3(0, 0,0)
@export var move_axis: Vector3 = Vector3(0, 0, 1) 
var locked = false
var lockVelocity:float = 15
var lockFov: float = 90.0
var lockSize: float = 14
var SetFov: float = 90.0
var SetSize: float = 14
var lockVector: Dictionary = {
	position = Vector3.ZERO,
	rotation = Vector3.ZERO
}
var plr
var realValue: float = 0
var moving = false
#THIS CODE IS SHIT. but im very lazy to optimize it rn
func _ready():
	projection = PROJECTION_PERSPECTIVE
func cameraFunc(delta):
	if GlobalVars.vars.worldMode == 1:
		plr.set_collision_mask_value(1,false)
		plr.set_collision_mask_value(2,true)
		#camera.set_orthogonal(cameraConfs.Orth.size,cameraConfs.Orth.near,cameraConfs.Orth.far)
		value = 1.0
		rotation = Vector3(0,0,0)
		var rot = Vector3(0,-plr.selfRot,0)
		plr.camNode.rotation = lerp(plr.camNode.rotation,rot,delta*15)
		plr.camNodeExtra.rotation = lerp(plr.camNodeExtra.rotation,Vector3.ZERO,delta*15)
	else:
		plr.set_collision_mask_value(1,true)
		plr.set_collision_mask_value(2,false)
		value = 0.0
func collisionRaycast():
	if plr == null:
		return
	if locked == true:return
	if GlobalVars.vars.worldMode == 1:return
	var space = get_world_3d().direct_space_state
	var parametters = PhysicsRayQueryParameters3D.create(
	plr.global_position, 
	plr.fakeCam.global_position
	)#plr.fakeCam.global_transform.origin)
	var mask = 1
	parametters.exclude = [$".",plr]
	parametters.collision_mask = mask
	var result = space.intersect_ray(parametters)
	if result:
		global_position = result.position + Vector3(0,.1,0)
	else:
		global_position = plr.fakeCam.global_position
func _unhandled_input(event: InputEvent) -> void: #camera movement
	if locked == true:return
	if moving == true:return
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	
	if event is InputEventMouseMotion and GlobalVars.vars.worldMode == 2:
		plr.camNode.rotate_y(-event.relative.x*.26/200)
		plr.camNodeExtra.rotate_x(-event.relative.y*.26/200)
		plr.camNodeExtra.rotation.x = clamp(plr.camNodeExtra.rotation.x,deg_to_rad(-80),deg_to_rad(80))
func _cameraLock(delta):
	top_level = true
	global_position = lerp(global_position,lockVector.position,lockVelocity*delta)
	if GlobalVars.vars.worldMode == 2:
		fov = lerpf(fov,lockFov,lockVelocity*delta)
		SetFov = lockFov
	else:
		size = lerpf(size,lockSize,lockVelocity*delta)
		SetSize = lockSize
var oldLocked = false
func _process(delta):
	if plr == null:
		plr = GlobalVars.vars.plr
		SetFov = plr.cameraConfs.Persp.fov
		SetSize = plr.cameraConfs.Orth.size
		return
	realValue = lerpf(realValue,value,delta*10)
	apply_transition(realValue,delta)
	cameraFunc(delta)

	if locked == true:
		oldLocked = true
		_cameraLock(delta)
		return
	else:
		var floorCamPos = Vector3(
			floor(global_position.x),
			floor(global_position.y),
			floor(global_position.z)
		)
		var floorFakeCamPos = Vector3(
			floor(plr.fakeCam.global_position.x),
			floor(plr.fakeCam.global_position.y),
			floor(plr.fakeCam.global_position.z)
		)
		if floorCamPos == floorFakeCamPos:
			oldLocked = false
		#print(global_position," ",plr.fakeCam.global_position)
		if floorCamPos != floorFakeCamPos and oldLocked == true:
			global_position = lerp(global_position,plr.fakeCam.global_position,lockVelocity*delta)
			moving = true
			return	
	top_level = false
	moving = false
	rotation = Vector3.ZERO
	#global_position = get_parent().global_positiona
	collisionRaycast()
#func _physics_process(delta: float) -> void:
	#if locked == true:return
	
func apply_transition(t: float,delta):
	if plr == null:return
	if locked == true:return
	top_level = false # this saved me HOURS. Thank you single line of code 💋❤! 
	var x = pow(max_multiplier, t) - 1.0
	var move = get_parent()
	SetSize = lerpf(SetSize,plr.cameraConfs.Orth.size,delta*7)
	SetFov = lerpf(SetFov,plr.cameraConfs.Persp.fov,delta*7)
	if t >= 0.89:
		set_orthogonal(SetSize,0.05,4000)
		move.position.z = 0
	else:
		
		set_perspective(SetFov / (1.0 + x),0.05,4000)
		move.position = base_position + move_axis.normalized() * x * SetFov/10
