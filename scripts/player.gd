extends CharacterBody3D
#nodes:
@onready var camera = $cam/extra/cam/move/Camera3D
@onready var moveCam = $cam/extra/cam
@onready var raypoint = $raycastPoint
@onready var ExtraForceRaypoint = $extraForceRaycast
@onready var camNode = $cam
@onready var camNodeExtra = $cam/extra
@export var model: Node3D
@onready var dummy = $dummy
@onready var animPlay = $model/AnimationPlayer
@onready var advantageRay = $JumpAdvngRaycast
@onready var fakeCam = $cam/extra/cam/move/fakeCam
@onready var musicNode = $cam/extra/cam/move/Camera3D/music
#scripts
@onready var movement = $movement
@onready var playerActions = $playerActions
@onready var animations = $animations
@onready var raycastScript = $raycast
#variables:
var extraVelocityConstant = false
var currAnim = ""
var lastAnimTransform = ""
var lastAnim = "nul"
var currAnimTransform = "nul"
var playerDirection: Vector3 = Vector3(0,0,0)
var extraForce: Vector3 = Vector3(0,0,0)
var timesJumpedMidAir: float = 0.0
var input_dir: Vector3 = Vector3(0,0,0)
var extraForceDir = 1
var inercy = false
var targetVel: Vector3 = Vector3.ZERO
var extraForceTime: float = 0
var keepDirectionOnExtraForce := false
var selfRot: float = 0
var LastWM = 2
var spawnPoint:Vector3 = Vector3(0,0,0)
var deadConditions = { #idk if im gonna use this again
		height = false
	}
@onready var space_state = get_world_3d().direct_space_state
var raycasts: Dictionary = {
	directionRaycast = null, #a raycast made in base were player is walking to
	extraForceRaycast = null # raycast directed to the ExtraForce variable
}
var timeStats: Dictionary = {
	wallJump = {
		time = 0,
		maxTime = 5
	},
	action2 = {
		time = 0,
		maxTime = 1
	},
	fallTime = 0,
}
var inputs = {
	jump = {
		actioned = false,
		time = 0,
		maxTime = .2,
		timesActioned = 0
	}
}
const stats: Dictionary = {
	weight = 55, #1 default
	acceleration = 15,
	speed = 16.0,
	runSpeed = 15.0,
	crouchSpeed = 6.5,
	maxSpeed = 18,
	jump_power = 18.0,
	hitbox = {
		normal = {
			pos = Vector3(0,0.644,0),
			size = Vector3(1,1,1)
		},
		crouching = {
			pos = Vector3(0,0.133,0),
			size = Vector3(1,0.567,1)
		},
	},
	action3 = { #slash/longjump
		twoD = {
			vec = Vector2(40,-30)
		},
		threeD = {
			vec = Vector2(45,10)
		}
	},
	walljump = {
		twoD = {
			force = Vector3(-22,13,-22)
		}
	},
}
var playerStates: Dictionary = {
	inAir = false,
	crouching = false,
	running = false,
	health = 100.0,
	dead = false,
	hitted = false,
	#actions
	inSlash = false,
	inLongJump = false,
	inWallJump = false
}
const cameraConfs: Dictionary = {
	Persp = {
		fov = 100,
		near = 0.05,
		far = 4000.0,
	},
	Orth = {
		size = 17.5,
		near = 0.05,
		far = 4000.0
	},
}

#all extra functions
func handleTime(delta):
	if playerStates.inAir == false and timeStats.fallTime > 0:
		timeStats.fallTime = 0
		inercy = false
		extraForceTime = 0
	if extraForceTime > 0:
		extraForceTime -= 1*delta
		if extraForceTime <= 0:
			extraForceTime = 0
func cancelAxis(vector,basis):
	if vector == Vector3.ZERO:
		return vector 
	var move_dir = vector.normalized()
	var forward_dir = -basis.z.normalized()
	var forward_component = move_dir.dot(forward_dir)
	move_dir -= forward_component * forward_dir
	move_dir = move_dir.normalized()
	var ret = Vector3(move_dir.x,0,move_dir.z)
	print(ret) #-debug
	return ret
func move_not_forward(basis): #get movement for 2d
	var input2vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_dir = Vector3(
		input2vec.x,
		0,
		input2vec.y
	)
	var newVector = cancelAxis(input_dir,basis)
	return newVector * stats.speed
func spawn():
	playerStates.health = 100
	playerStates.dead = false
	global_position = spawnPoint
	musicNode.setVolume = musicNode.ogVolume
	musicNode.setPitch = musicNode.ogPitch
	musicNode.transitionSpeed = 2
	camera.lockVelocity = 2.3
	camera.locked = false
	deadConditions.height = false
func die():
	if playerStates.dead == true:return
	playerStates.health = 0
	playerStates.dead = true
	#camera pos
	var offset = Vector3(0,1,0)
	var lookVel = 1
	if deadConditions.height:
		offset = Vector3(0,-2,0)
		lookVel = 15
	camera.lockVector.position = camera.global_position+offset
	camera.lockVelocity = lookVel
	camera.locked = true
	#music Volume
	musicNode.setVolume = -8
	musicNode.setPitch = .65
	musicNode.transitionSpeed = .5
	await get_tree().create_timer(5).timeout
	spawn()
func playerSetStates():
	if extraForceTime <= 0 and extraVelocityConstant == false :
		playerStates.inSlash = false
	if playerStates.inAir == true and velocity.y == 0:
		playerStates.inLongJump = false
	if  extraForceTime <= 0 and playerStates.inAir == false:
		playerStates.inWallJump = false
	if extraVelocityConstant == true and playerStates.inAir == false:
		extraVelocityConstant = false
func inputOnFloor() -> void:
	var jumpTime = GlobalVars.vars.time-inputs.jump.time
	if jumpTime <= inputs.jump.maxTime and inputs.jump.actioned == true:
		inputs.jump.actioned = false
		playerActions.action1()
		playerActions.action2()
func _input(event: InputEvent) -> void: #all input
	if playerStates.dead:return
	if event is InputEventKey and playerStates.hitted == false:
		if event.keycode == KEY_SPACE and event.pressed: #jump/double jump
			playerActions.action1()
			playerActions.action2()
			if playerStates.inAir == true:
				inputs.jump.time = GlobalVars.vars.time
				inputs.jump.actioned = true
		if event.keycode == KEY_2 and event.pressed: #slash/long jump
			playerActions.action3()
		if event.keycode == KEY_CTRL and event.pressed: #crouch
			playerActions.action4()
		#if event.keycode == KEY_SHIFT and event.pressed: #run
			#playerActions.action5()
		#debug
		if event.keycode == KEY_1 and event.pressed:
			get_parent().get_parent()._switchWorldMode()
		if event.keycode == KEY_5 and event.pressed:
			position = Vector3(0,1,0)
		if event.keycode == KEY_6 and event.pressed:
			playerStates.health -= 1
		if event.keycode == KEY_7 and event.pressed:
			playerStates.health += 1
func visualPlayerAngle(delta):
	if playerDirection != Vector3.ZERO and keepDirectionOnExtraForce == false:
		var target = dummy.global_position+playerDirection
		if inercy == true:
			target = dummy.global_position+extraForce
		target.y = dummy.global_position.y
		if target != dummy.global_position:
			dummy.look_at(target)
		var offset = 0
		
		if GlobalVars.vars.worldMode == 1  and animations.rotateModelIn2d :
			var angle_deg = 55 * input_dir.x #multiply by direction (1, 0 or -1)
			var angle_rad = angle_deg * PI / 180.0 
			offset = -angle_rad #change offsset to inverted angle
		rot = dummy.global_rotation.y + offset
	var speed = 10
	if GlobalVars.vars.worldMode == 1:
		model.global_rotation.y = rot
	else:
		model.global_rotation.y = lerp_angle(model.global_rotation.y,rot,delta*10)
func _ready() -> void:
	GlobalVars.vars.plr = $"."
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spawnPoint = global_position
	musicNode.start(get_tree().current_scene.songs)
func _physics_process(delta: float) -> void:
	if GlobalVars.vars.plr == null:return
	if not animations:return
	if not movement:return
	if not playerActions:return
	#set states
	playerStates.inAir = not is_on_floor()
	if 	playerStates.inAir == true: #air conditions
		timeStats.fallTime += delta
	else:
		timesJumpedMidAir = 0
		if playerActions.advantages.jump == true:
			playerActions.advantages.jump = false

	#set conditions
	animations.anims(delta)
	animations.animsTransform(delta)
	animations.animsConditions()
	movement.get_Velocity(delta)
	playerActions.actions_conditions(delta)
	playerActions.advantages_conditions(delta)
	move_and_slide()
func collMask():
	if GlobalVars.vars.worldMode == 1:
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,true)
	else:
		set_collision_mask_value(1,true)
		set_collision_mask_value(2,false)
func constantDeathConditions():
	if GlobalVars.vars.actualScene == null:return
	if playerStates.health <= 0: #die by life
		die()
	var minY = GlobalVars.vars.actualScene.minY
	if global_position.y < minY: #die by height
		deadConditions.height = true
		die()
# Called every frame. 'delta' is the elapsed time since the previous frame.
var lastvel = Vector3.ZERO
var rot = -2.5
var wasOnFloor = false
func _process(delta: float) -> void:
	handleTime(delta)
	collMask()
	playerSetStates()
	raycastScript.raycastsDetections(delta)
	if wasOnFloor != is_on_floor() and playerStates.inAir == false:
		wasOnFloor = is_on_floor()
		inputOnFloor()
	visualPlayerAngle(delta)
	constantDeathConditions()
	
	
