extends CharacterBody3D
@export var behaviorScript: Node
@export var stats: Dictionary = {
	health = 0.0,
	
}
var  plr = null
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _input(event: InputEvent) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr 
	
	if event is InputEventKey:
		if event.keycode == KEY_O and event.pressed:
			plr.movement._knockBack(global_position,10)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
