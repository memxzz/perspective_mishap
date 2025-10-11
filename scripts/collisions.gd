extends Node
var plr
var lastObject = null
var lastObjId
var objId
var obj
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	var raycast = plr.raycasts.extraForceRaycast
	if raycast == null or raycast.is_empty():return
	if raycast["collider"] == null:return
	if raycast["collider"].has_meta("collidable") == false:return
	if raycast["collider"].get_meta("collidable") == false:return
	obj = raycast["collider"]
	objId = raycast["collider"].name

	if objId != lastObjId:
		
		lastObject = obj
		lastObjId = objId
	obj.collide()
