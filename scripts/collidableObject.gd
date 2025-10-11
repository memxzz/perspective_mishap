extends StaticBody3D
var collided = false
var plr
@export var breakable = false
@export var breakObj: PackedScene
@export var normalObj: Node
@onready var explosionSFX = $particles/explosion
@onready var particles = $particles
@onready var sound = get_parent().get_node("AudioStreamPlayer3D")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = name+str(GlobalVars.vars.time)
	particles.top_level = true
func destroy():
	print("yey")
	sound.play()
	var inst = breakObj.instantiate()
	inst.transform = normalObj.transform
	get_parent().add_child(inst)
	normalObj.queue_free()
	self.queue_free()
func collide():
	
	if plr == null:
		plr = GlobalVars.vars.plr
	if plr == null:return
	if collided == true:return
	if plr.playerStates.inSlash == false:return
	collided = true
	print("huh")
	if breakable == true:
		destroy()
