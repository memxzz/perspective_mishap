extends CharacterBody3D
@export var behaviorScript: Node
@export var stats: Dictionary = {
	health = 0.0,
	speed = 0.0,
	jump_vel = 0.0,
	aceleration = 0.0,

}
@export var behaviorStats = {
	target_vel = Vector3.ZERO,
	inAir = false,
	extraForce = Vector3.ZERO, #this one is for command enemy where to go
	extraForceTime = 0,
	inercy = false,
	hasGravity = true,
}
var plr = null
var wasOnFloor: bool = false
var targetVel: Vector3 #this one is for extraForce
#scripts:
@export var behaviorFunctions: Node
@export var behavior: Node
func cancelAxis(vector,basis):
	if vector == Vector3.ZERO:
		return vector 
	var move_dir = vector.normalized()
	var forward_dir = -basis.z.normalized()
	var forward_component = move_dir.dot(forward_dir)
	move_dir -= forward_component * forward_dir
	move_dir = move_dir.normalized()
	var ret = Vector3(move_dir.x,0,move_dir.z)
	return ret
func _knockBack(origin: Vector3, force: float):
	behaviorStats.extraForce = (global_transform.origin - origin).normalized() * force 
	print((global_transform.origin - origin).normalized())
	behaviorStats.extraForce.y = force
	behaviorStats.extraForceTime = .15
	behaviorStats.inercy = true
func extraForce(delta):
	if not behaviorStats.inercy and behaviorStats.extraForceTime <= 0:
		behaviorStats.extraForce = Vector3.ZERO
	if behaviorStats.extraForceTime > 0:
		behaviorStats.extraForceTime -= delta		
		if GlobalVars.vars.worldMode == 1:
			targetVel = cancelAxis(behaviorStats.extraForce,transform.basis) * Vector3(
				abs(behaviorStats.extraForce.x),
				abs(behaviorStats.extraForce.y),
				abs(behaviorStats.extraForce.z)
				)
		else:
			targetVel = behaviorStats.extraForce
		velocity.y = behaviorStats.extraForce.y
func _damage(damage):
	print(damage)
	stats.health -= damage
	_knockBack(plr.global_position,10)
	if stats.health <= 0:
		$".".queue_free()
func _input(event: InputEvent) -> void: #-debug
	if plr == null:
		plr = GlobalVars.vars.plr 
	if event is InputEventKey:
		if event.keycode == KEY_O and event.pressed:
			plr.movement._knockBack(global_position,10)
		if event.keycode == KEY_P and event.pressed:
			_damage(10)
func _physics_process(delta: float) -> void:
	if behaviorStats.inAir == true and behaviorStats.extraForceTime <= 0 and behaviorStats.hasGravity:
		velocity.y += get_gravity().y * delta
	var direction = (transform.basis * behaviorStats.target_vel).normalized()
	behaviorStats.inAir = not is_on_floor()
	extraForce(delta)
	if behaviorStats.extraForceTime <= 0 and behaviorStats.inercy == false:
		if direction:
			targetVel.x = direction.x * stats.speed
			targetVel.z = direction.z * stats.speed
		else:
			targetVel.x = move_toward(velocity.x, 0, stats.speed)
			targetVel.z = move_toward(velocity.z, 0, stats.speed)
	velocity.x = lerpf(velocity.x,targetVel.x,stats.aceleration*delta)
	velocity.z = lerpf(velocity.z,targetVel.z,stats.aceleration*delta)
	if not behaviorStats.hasGravity:
		velocity.y = lerpf(velocity.y,behaviorStats.target_vel.y,stats.aceleration*delta)

	move_and_slide()
func _process(delta):
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	behaviorFunctions.followTarget(plr,10)
	if wasOnFloor != is_on_floor():
		wasOnFloor = is_on_floor()
		behaviorStats.inAir = not is_on_floor()
		if is_on_floor() == true:
			behaviorStats.inercy = false
