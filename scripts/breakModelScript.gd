extends Node3D
@export var intensity:float = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pieces:RigidBody3D in self.get_children():
		pieces.apply_impulse(pieces.get_child(0).position * intensity,self.global_position);
		pieces.add_collision_exception_with(GlobalVars.vars.plr)
		pieces.collision_layer = 0
	await get_tree().create_timer(5).timeout
	queue_free()
