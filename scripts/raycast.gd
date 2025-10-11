extends Node
@export var advntgJumpRaycast: RayCast3D
var plr
const playerDirectionLenght := .8
const extraForceLenght := 1
#this code is ok actually
func raycast(origin,dir,lenght,excludeCord): #function for raycast
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	dir = dir * excludeCord
	var end = origin + dir * lenght
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var mask = 1
	query.exclude = [self,$".",plr]
	if GlobalVars.vars.worldMode == 2:
		mask = 1
	else:
		mask = 2
	query.collision_mask = mask
	query.collide_with_areas = false
	return query

		#camera.set_perspective(cameraConfs.Persp.fov,cameraConfs.Persp.near,cameraConfs.Persp.far)
#all needed functions
func raycastsDetections(delta):
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	#PlayerDirection
	var direction = plr.playerDirection
	var Query = raycast(plr.global_position,direction.normalized(),playerDirectionLenght,Vector3(1,0,1)) 
	var Result = plr.space_state.intersect_ray(Query)
	if Result:
		plr.raypoint.global_position = Result.position
	#ExtraForce
	var ExtraForce = plr.extraForce
	var EFRaycastQuery = raycast(plr.global_position-Vector3(0,.3,0),ExtraForce.normalized(),extraForceLenght,Vector3(1,1,1))
	var EFResult = plr.space_state.intersect_ray(EFRaycastQuery)
	if EFResult:
		plr.ExtraForceRaypoint.global_position = EFResult.position
	plr.raycasts.directionRaycast = Result #set the direction raycast variable to result
	plr.raycasts.extraForceRaycast = EFResult #set the extraForceRaycast variable to EF result
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	var mask = 1
	if GlobalVars.vars.worldMode == 2:
		mask = 1
	else:
		mask = 2
	advntgJumpRaycast.collision_mask = mask
	advntgJumpRaycast.position = -plr.playerDirection * 2.4
	advntgJumpRaycast.position.y = 1
