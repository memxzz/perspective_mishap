extends CharacterBody3D
@export var behaviorScript: Node
@export var stats: Dictionary = {
	health = 0.0,
	speed = 0.0,
	jump_vel = 0.0,
	aceleration = 0.0

}
var  plr = null
var extraforce: Vector3
var extraforceTime: float
var inercy: bool
var inAir = false
var wasOnFloor: bool = false
var wantedVel = 0
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
	extraforce = (global_transform.origin - origin).normalized() * force 
	print((global_transform.origin - origin).normalized())
	extraforce.y = force
	extraforceTime = .15
	inercy = true
func extraForce(delta):
	if not inercy and extraforceTime <= 0:
		extraforce = Vector3.ZERO
	if extraforceTime > 0:
		extraforceTime -= delta		
		if GlobalVars.vars.worldMode == 1:
			velocity = cancelAxis(extraforce,transform.basis) * Vector3(
				abs(extraforce.x),
				abs(extraforce.y),
				abs(extraforce.z)
				)
		else:
			velocity = extraforce
		velocity.y = extraforce.y
func _damage(damage):
	print(damage)
	stats.health -= damage
	_knockBack(plr.global_position,10)
func _input(event: InputEvent) -> void: #-debug
	if plr == null:
		plr = GlobalVars.vars.plr 
	
	if event is InputEventKey:
		if event.keycode == KEY_O and event.pressed:
			plr.movement._knockBack(global_position,10)
		if event.keycode == KEY_P and event.pressed:
			_damage(10)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not inercy and extraforceTime <= 0:
		velocity += get_gravity() * delta
	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	inAir = not is_on_floor()
	extraForce(delta)
	if extraforceTime <= 0 and inercy == false:
		if direction:
			velocity.x = direction.x * stats.speed
			velocity.z = direction.z * stats.speed
		else:
			velocity.x = move_toward(velocity.x, 0, stats.speed)
			velocity.z = move_toward(velocity.z, 0, stats.speed)
	move_and_slide()
func _process(delta):
	if wasOnFloor != is_on_floor():
		wasOnFloor = is_on_floor()
		inAir = not is_on_floor()
		if is_on_floor() == true:
			inercy = false
	print(extraforce,extraforceTime,inercy)
