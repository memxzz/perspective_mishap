extends Node
var plr
var playingCustom = false
var blendTime = .1
var rotateModelIn2d = true
const animationTransforms = {
	crouching = {
		size = Vector3(1.393,0.779,1.393),
		pos = Vector3(0,-0.551,0),
		time = 15
	},
	normal = {
		size = Vector3(1,1.199,0.897),
		pos = Vector3(0,-0.551,-0.03),
		time = 15
	}
}
func animsTransform(delta):  #for animations that just change transform
	if not plr.currAnimTransform in animationTransforms:
		return
	var anim = plr.currAnimTransform
	var scale = plr.model.scale
	var pos = plr.model.position
	var transform = animationTransforms[anim]
	plr.model.scale = lerp(scale,transform.size,delta*transform.time)
	plr.model.position = lerp(pos,transform.pos,delta*transform.time)
func anims(delta):
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	if plr.lastAnim == plr.currAnim:return
	plr.lastAnim = plr.currAnim
	plr.animPlay.playback_default_blend_time = blendTime

	plr.animPlay.play(plr.currAnim)
	plr.animPlay.timer()

func animsConditions():
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	if playingCustom == true:return
	#transform anims
	blendTime = .1
	rotateModelIn2d = true
	if plr.playerStates.crouching == true:
		plr.currAnimTransform = "crouching"
	else:
		plr.currAnimTransform = "normal"
	#normal anims
	if plr.playerStates.inSlash == true:
		#plr.currAnim = "slash"
		return
	if plr.playerStates.inLongJump == true:
		plr.currAnim = "longJump"
		blendTime = .3
		return
	if plr.playerActions.actions.wallJump == true:
		plr.currAnim = "wall-left"
		
		blendTime = 0
		rotateModelIn2d = false
		return
	if plr.playerStates.inAir == true and plr.velocity.y < 0:
		plr.currAnim = "falling"
		blendTime = .2
		return
	if plr.playerStates.inAir == true and plr.velocity.y > 0:
		plr.currAnim = "jump"
		blendTime = .1
		return
	if plr.playerDirection != Vector3.ZERO and plr.playerStates.inAir == false:
		plr.currAnim = "walk"
		return

	plr.currAnim = "Idle" #play idle if animation has not been changed
	
	
