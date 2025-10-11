extends Node
var plr
@export var particlesNode: Node3D
@onready var walkParticles = particlesNode.get_node("walkParticles")
@export var plrCloneNode: PackedScene
@export var sourceMesh: MeshInstance3D
var time = {
	walkParticle = {
		time = 0,
		maxTime = .3
	},
	trailEffect = {
		time = 0,
		maxTime = .1
	}
}
var lastSlash = false
func cloneMesh():
	var scene := plrCloneNode.instantiate()
	scene.mesh = sourceMesh.bake_mesh_from_current_skeleton_pose()
	scene.global_transform = sourceMesh.global_transform
	scene.top_level = true
	scene.material_override.albedo_color = Color(randf(), randf(), randf())
	particlesNode.add_child(scene)
	return scene
func _walkParticles(delta):
	if plr.playerDirection != Vector3.ZERO and plr.playerStates.inAir == false:
		time.walkParticle.time += delta
		if time.walkParticle.time >= time.walkParticle.maxTime:
			walkParticles.emitting = true
			time.walkParticle.time = 0
func _trailEffect(delta):
	time.trailEffect.time += delta
	if plr.playerStates.inSlash == false:
		return
	if time.trailEffect.time >= time.trailEffect.maxTime:
		time.trailEffect.time  = 0
	else:
		return
	var cloneModel = cloneMesh()
	cloneModel.top_level = true
	await get_tree().create_timer(.4).timeout
	cloneModel.queue_free()
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr 
		return
	_walkParticles(delta)
	_trailEffect(delta)
	
