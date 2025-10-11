extends Area3D
@export var damage: float = 0
func _on_body_entered(body: Node3D) -> void:
	if not GlobalVars.vars.actualScene:return
	if body is CharacterBody3D:
		if body.playerStates.dead:return
		body.playerStates.health -= damage
	
		
