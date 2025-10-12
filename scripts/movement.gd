extends Node
var plr
var speed = 0
#this code is NOT ok:
#I really should improve it but im very lazy

#ok i improved it c:
func _ready() -> void:
	plr = GlobalVars.vars.plr
func extraForce():
	#extra force
	if not plr.inercy and not plr.extraVelocityConstant and plr.extraForceTime <= 0:
		plr.extraForce = Vector3.ZERO
		plr.keepDirectionOnExtraForce = false
		if plr.playerStates.inKnockback == true:
			plr.playerStates.inKnockback = false
	if plr.extraForceTime > 0:
		if GlobalVars.vars.worldMode == 1:
			
			var axis = plr.cancelAxis(plr.extraForce,plr.camNode.transform.basis) * Vector3(
				abs(plr.extraForce.x),
				abs(plr.extraForce.y),
				abs(plr.extraForce.z)
				)
			
			plr.targetVel = axis
		else:
			plr.targetVel = plr.extraForce
		
		plr.velocity.y =  plr.extraForce.y
func gravityAndMovement(delta):
	#set gravity and weight
	if plr.playerStates.inAir == true and plr.extraForceTime <= 0:
		plr.velocity.y += (-plr.stats.weight - 9.8) * delta
	#movement
	if plr.extraForceTime <= 0 and plr.inercy == false:
		if plr.playerDirection:
			plr.targetVel.x = plr.playerDirection.x * speed
			plr.targetVel.z = plr.playerDirection.z * speed
		else:
			plr.targetVel.x = move_toward(0, 0, speed)
			plr.targetVel.z = move_toward(0, 0, speed)
func velocityAceleration(delta,nBasis):
	#lerp from real velocity (the one from the class CharacterBody) to te variable so
	#velocity has like a cool "aceleration".
	if GlobalVars.vars.worldMode == 1 and plr.extraForceTime <= 0 and plr.inercy == false:
		#in case player is in 2d world then cancel player's own "z" movement
		var new_move = plr.move_not_forward(nBasis)
		plr.targetVel.x = new_move.x
		plr.targetVel.z = new_move.z
	if plr.playerStates.health <= 0:return
	plr.velocity.x = lerpf(plr.velocity.x,plr.targetVel.x,plr.stats.acceleration*delta)
	plr.velocity.z = lerpf(plr.velocity.z,plr.targetVel.z,plr.stats.acceleration*delta)
func get_Velocity(delta):
	if plr == null: 
		plr = GlobalVars.vars.plr 
		return
	#Set player direction
	var nBasis = plr.camNode.transform.basis
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	plr.playerDirection = (nBasis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	extraForce()
	gravityAndMovement(delta)
	velocityAceleration(delta,nBasis)
func _knockBack(origin: Vector3, force: float):
	plr.extraForce = (plr.global_transform.origin - origin).normalized() * force 
	print((plr.global_transform.origin - origin).normalized())
	plr.extraForce.y = force
	plr.extraForceTime = .15
	plr.keepDirectionOnExtraForce = true
	plr.playerStates.inKnockback = true
	plr.inercy = true
func _process(delta: float) -> void: 
	#state speeds
	if plr == null:return
	if plr.playerStates.crouching == true:
		speed = plr.stats.crouchSpeed
	else:
		if plr.playerStates.running == false:
			speed = plr.stats.speed
		else:
			speed = plr.stats.runSpeed
	
