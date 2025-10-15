extends CharacterBody3D
class_name Enemy
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
#nodes
#scripts:
@export var behaviorFunctions: Node
@export var behavior: Node
@export var hitbox: Area3D

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
func _knockBack(origin: Vector3, force: float) -> void:
	behaviorStats.extraForce = (global_transform.origin - origin).normalized() * force 
	print((global_transform.origin - origin).normalized())
	behaviorStats.extraForce.y = force
	behaviorStats.extraForceTime = .15
	behaviorStats.inercy = true
func extraForce(delta) -> void:
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
func _damage(damage) -> void:
	print(damage)
	stats.health -= damage
	_knockBack(plr.global_position,10)
	if stats.health <= 0:
		$".".queue_free()
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
func _process(delta) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	behaviorFunctions.followTarget(plr,10)
	if wasOnFloor != is_on_floor():
		wasOnFloor = is_on_floor()
		behaviorStats.inAir = not is_on_floor()
		if is_on_floor() == true:
			behaviorStats.inercy = false
func _onHitbox_enter(body: Node3D) -> void:
	
	if not body is Player:return
	body._damage({
		damage = 20,
		knockbackForce = 10,
		damager = self
	})
func _ready() -> void:
	if hitbox:
		hitbox.body_entered.connect(_onHitbox_enter)
