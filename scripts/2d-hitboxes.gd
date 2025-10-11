extends Node3D
@onready var TWODPlatforms = $"2d platforms"
@onready var THREEDPlatforms = $"3d platforms"
@onready var objects = $"objects"
@onready var objects2d = $"objects2d"
@export var songs: Array
@export var minY: float
var dir = Vector3(1,0,0).normalized()
var center = Vector3(0,0,0)
var startPoint = Vector2(0,0)

func proyect(pos_objeto: Vector3, origin: Vector3, dir: Vector3) -> Vector3:
	var d = dir.normalized()
	var t = (pos_objeto - origin).dot(d)
	var a = origin + d * t
	a.y = pos_objeto.y
	return a
func setObjectProy(children,rotate,rot,place):
	var nch = children.duplicate()
	place.add_child(nch)
	nch.global_position = proyect(children.global_position,center,dir)
	if rotate == true:
		nch.global_rotation.y = rot
	nch.scale = children.scale
	if children.has_meta("offset") == true:
		nch.global_position += nch.get_meta("offset")
	if place.name == "objects" or place.name == "objects2d":
		return
	nch.get_children()[0].set_collision_layer_value(2,true)
	nch.get_children()[0].set_collision_layer_value(1,false)
	nch.get_children()[0].set_collision_mask_value(2,true)
	nch.get_children()[0].set_collision_mask_value(1,false)
	children.get_children()[0].set_collision_mask_value(2,false)
	children.get_children()[0].set_collision_mask_value(1,true)
func _create2dHitBoxes(rot,rotate) -> void:
	if GlobalVars.vars.plr == null:
		return
	for children in THREEDPlatforms.get_children():
		setObjectProy(children,rotate,rot,TWODPlatforms)
	for children in objects.get_children():
		setObjectProy(children,rotate,rot,objects2d)
func rotateAll(rot,og,rotate):
	for children in TWODPlatforms.get_children():
		children.queue_free()
	for children in objects2d.get_children():
		children.queue_free()
	var angle_deg = rot
	var angle_rad = angle_deg * PI / 180.0
	dir = Vector3(sin(angle_rad), 0, cos(angle_rad)).normalized()
	if rot == 0:
		dir = Vector3(1,0,0)
	if rot == 90:
		dir = Vector3(0,0,1)
	if rot == -90:
		dir = Vector3(0,0,-1)
	center = og
	GlobalVars.vars.plr.selfRot = angle_rad 
	_create2dHitBoxes(angle_rad,rotate)
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_4 and event.pressed:
			var pos = GlobalVars.vars.plr.global_position
			pos.y = 0
			rotateAll(0,pos,false)
func _switchWorldMode():
	if GlobalVars.vars.worldMode == 1:
		GlobalVars.vars.worldMode = 2
	else:
		GlobalVars.vars.worldMode = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.vars.actualScene = $"."
	_create2dHitBoxes(0,false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if GlobalVars.vars.plr == null:
		return
	if GlobalVars.vars.plr.camera.value >= 0.89:
		TWODPlatforms.visible = true
		THREEDPlatforms.visible = false
		objects2d.visible = true
		objects.visible = false
	else:
		TWODPlatforms.visible = false
		THREEDPlatforms.visible = true
		objects2d.visible = false
		objects.visible = true
