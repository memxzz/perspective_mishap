extends Node
var advantages: Dictionary = {
	jump = false,
}
var actions: Dictionary = {
	wallJump = false,
	canJump = false,
	canSlash = false
}
var actionsVariables = {
	tripleJump = {
		multiplier = 0, #jeje markiplier
		multiplierVar = 0.45
	},
	wallJump = {
		direction = 1 #-1 left 1 right
	}
}
var actionsTimes = {
	tripleJump = {
		savedTime = 0
	}
}
var timesJumped:int = 0
var time:float = 0
var floorTime:float = 0
var plr
#THISS IS SHIT I HATE IT SO MUCh
func actions_conditions(delta):
	plr = GlobalVars.vars.plr
	if plr.playerStates.dead == true:return
	#wall jump
	if plr.raycasts.directionRaycast != null and plr.raycasts.directionRaycast.has("collider"):
		plr.timeStats.wallJump.time += delta
		var rayResult = plr.raycasts.directionRaycast
		var obj = rayResult.collider.get_parent()
		if obj.get_meta("walljumpable") == true:
			actions.wallJump = true
		else:
			actions.wallJump = false
	else:
		actions.wallJump = false
	#jumping
	if plr.playerStates.inAir == false or (GlobalVars.vars.worldMode == 1 and plr.timesJumpedMidAir < 1 and plr.playerStates.inAir == true) or advantages.jump == true:
		actions.canJump = true
		
	else:
		actions.canJump = false
	#slash/long jump
	if plr.extraForceTime <= 0 and plr.timeStats.action2.time < plr.timeStats.action2.maxTime:
		actions.canSlash = true
	else:
		actions.canSlash = false
		
func advantages_conditions(delta):
	plr = GlobalVars.vars.plr
	if plr.playerStates.dead == true:return
	if plr == null:
		return
	if plr.advantageRay.is_colliding() and plr.playerStates.inAir == true:
		advantages.jump = true
	else:
		advantages.jump = false
func action1(): #jump #plz someone help me im dying for this
	plr = GlobalVars.vars.plr
	if plr.playerStates.dead == true:return
	if plr.playerStates.crouching == true:return
	if actions.canJump == false:return
	if plr.playerStates.inAir == true and advantages.jump == false:plr.timesJumpedMidAir += 1
	if floorTime-actionsTimes.tripleJump.savedTime > .25:
		actionsVariables.tripleJump.multiplier = 0
		timesJumped = 0
	if plr.playerStates.inAir == false and GlobalVars.vars.worldMode == 2:
		timesJumped += 1
		actionsVariables.tripleJump.multiplier += actionsVariables.tripleJump.multiplierVar
		actionsTimes.tripleJump.savedTime = floorTime
	if timesJumped <= 1:
		actionsVariables.tripleJump.multiplier = 0
	if actionsVariables.tripleJump.multiplier > actionsVariables.tripleJump.multiplierVar * 2:
		actionsVariables.tripleJump.multiplier = 0	
	if plr.playerDirection == Vector3.ZERO and timesJumped > 2:
		timesJumped = 1
		actionsVariables.tripleJump.multiplier = 0
	var vely = plr.stats.jump_power * actionsVariables.tripleJump.multiplier
	plr.velocity.y = plr.stats.jump_power+vely
func action2(): #wall jump
	plr = GlobalVars.vars.plr
	if plr.playerStates.crouching == true:return
	if plr.playerStates.dead == true:return
	plr.extraForceTime = 0
	if actions.wallJump == true:
		plr.playerStates.inWallJump = true
		var direction = plr.playerDirection 
		var force = plr.stats.walljump.twoD.force
		var dir = sign(plr.input_dir.x)
		print(direction)
		if dir == 0:
			dir = 1
		plr.extraForceDir = dir * -1
		plr.extraForce = direction * force #* (dir*(-1))
		plr.extraForce.y = force.y
		plr.extraForceTime = .15
		plr.inercy = true
		actions.canWallJump = false
func action3(): #slash/long jump
	plr = GlobalVars.vars.plr
	if actions.canSlash == false:return
	if plr.playerStates.crouching == true:return
	if plr.playerStates.dead == true:return
	var direction = plr.playerDirection
	plr.timeStats.time = 0
	if GlobalVars.vars.worldMode == 2:
		if plr.playerStates.inAir == true:
			return
		plr.extraForce.x = direction.x * plr.stats.action3.threeD.vec.x/2.2
		plr.extraForce.z = direction.z * plr.stats.action3.threeD.vec.x/2.2
		plr.extraForce.y = plr.stats.action3.threeD.vec.y
		plr.extraForceTime = .15
		plr.inercy = true
		plr.playerStates.inLongJump =  true
	else:
		plr.playerStates.inSlash = true
		var dir = sign(plr.input_dir.x)
		plr.extraForceDir = dir
		if dir == 0:
			return
		var force = plr.stats.action3.twoD.vec.x
		if plr.playerStates.inAir == false:
			force *= 1.25
		force *= direction
		plr.extraForce = force
		if plr.playerStates.inAir == true:
			plr.extraForce.y = plr.stats.action3.twoD.vec.y
			plr.extraVelocityConstant = true
		else:
			plr.extraForce.y = 0
		plr.extraForceTime = .3
		plr.inercy = false
func action4(): #crouch
	plr = GlobalVars.vars.plr
	if plr.playerStates.dead == true:return
	if plr.playerStates.inAir == true:
		plr.playerStates.crouching = false
		return
	plr.playerStates.running = false
	plr.playerStates.crouching = not plr.playerStates.crouching
func action5(): #run
	plr = GlobalVars.vars.plr
	if plr.playerStates.dead == true:
		plr.playerStates.running = false
		return
	if plr.playerStates.inAir == true:
		plr.playerStates.running = false
		return
	if plr.playerStates.crouching == true:
		plr.playerStates.running = false
		return
	plr.playerStates.running = true
func actionsConstant():
	if plr.playerStates.inWallJump:
		var force = plr.stats.walljump.twoD.force
		plr.extraForce.y = force.y
	if actions.wallJump == true and plr.playerStates.inWallJump == false:
		plr.extraForceTime = .2
		plr.extraForce.y = -3
func _process(delta: float) -> void:
	plr = GlobalVars.vars.plr
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	time += delta
	if plr.is_on_floor():
		floorTime += delta
	actionsConstant()
	#print(actionsVariables.tripleJump.multiplier)
