extends Node3D
var plr
@onready var sprite = $Node3D/Sprite3D
@onready var node = $Node3D
@onready var richtext  = $Node3D/SubViewport/Control/RichTextLabel
@onready var subView = $Node3D/SubViewport
@export var distance: float
@export var alphaOffset: float
@export var hitbox: Node3D
@export var excludeWorldMode: int = 0
@export var rotation2d := Vector3.ZERO
@export var text: String
func _ready() -> void:
	sprite.modulate.a = 0
	richtext.text = text
	sprite.texture = subView.get_texture()
	print("h e "+str(sprite.rotation.y))
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	if hitbox == null:return
	var dist = clamp(plr.global_position.distance_to(hitbox.global_position),0,distance)
	var val = 1-(dist/distance)
	
	sprite.modulate.a = lerp(sprite.modulate.a,val + alphaOffset,delta*8)
	if GlobalVars.vars.worldMode == excludeWorldMode:
		sprite.modulate.a = 0
	if GlobalVars.vars.worldMode == 1:
		node.rotation = rotation2d
		#print("h e "+str(sprite.rotation))
		return
	node.look_at(plr.camera.global_position)
	#node.rotation.y
