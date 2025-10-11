extends Node
var plr
@export var collisionShape: CollisionShape3D
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	if plr.playerStates.crouching == true:
		collisionShape.scale = plr.stats.hitbox.crouching.size
		collisionShape.position = plr.stats.hitbox.crouching.pos
	else:
		collisionShape.scale = plr.stats.hitbox.normal.size
		collisionShape.position = plr.stats.hitbox.normal.pos
