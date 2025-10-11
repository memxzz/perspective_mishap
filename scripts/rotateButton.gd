extends Area3D
func _on_body_entered(body: Node3D) -> void:
	if not GlobalVars.vars.actualScene:return
	if body is CharacterBody3D:
		if get_meta("used") == true:
			return
		set_meta("used",true)
		GlobalVars.vars.actualScene.rotateAll(get_meta("angle"),global_position,get_meta("rotateObjects"))
		GlobalVars.vars.worldMode = get_meta("worldmode")
		GlobalVars.vars.plr.spawnPoint = global_position
	
		
