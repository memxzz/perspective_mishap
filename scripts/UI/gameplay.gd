extends Control
@onready var FPS = $FPS
@onready var ICON = $health/icon
@onready var ICON_OUTLINE = $health/iconOutline
var val = 0
var def_posIcon = Vector2(-11.0,509.0)
var def_posIconOutline = Vector2(1.0,521.0)
var plr
var time: float = 0
func setPivots():
	ICON_OUTLINE.pivot_offset = ICON_OUTLINE.size/2
	ICON.pivot_offset = ICON.size/2
func ICON_POS(delta):
	if val <= .3 and not plr.playerStates.dead:
		#outline
		ICON_OUTLINE.position.x = sin(time*50) + def_posIconOutline.x
		ICON_OUTLINE.position.y = sin(time*30) + def_posIconOutline.y
		#icon:
		ICON.position.x = sin(time*30) + def_posIcon.x
		ICON.position.y = sin(time*10) + def_posIcon.y
		return
	if plr.playerStates.dead == true:
		var timeMultiplier = 1.2 #jeje timeMarkiplier
		var sinMultiplier = .2 #jeje sinMultipli-no
		var lerpSpeed = 5
		ICON_OUTLINE.rotation = lerp(
			ICON_OUTLINE.rotation,
			sin(time*timeMultiplier)*sinMultiplier,
			delta*lerpSpeed
			)
		ICON.rotation = lerp(
			ICON.rotation,
			sin(time*timeMultiplier)*sinMultiplier,
			delta*lerpSpeed
			)
		return
	#icon
	var speed = 5
	ICON.rotation = lerpf(ICON.rotation,0,delta*speed)
	ICON.position = lerp(ICON.position,def_posIcon,delta*speed)
	#outline
	ICON_OUTLINE.position = lerp(ICON_OUTLINE.position,def_posIconOutline,delta*speed)
	ICON_OUTLINE.rotation = lerpf(ICON_OUTLINE.rotation,0,delta*speed)
func ICON_VAL(delta):
	var hlthCos = plr.playerStates.health/100.0
	var vel = 15
	if plr.playerStates.dead == true:
		vel = 3
	val = lerpf(ICON.material.get_shader_parameter("val"),hlthCos,vel*delta)
	var from_fill = ICON.material.get_shader_parameter("Dtexture")
	var valueX = 0
	var valueY = 0
	if val <= .9 and plr.playerStates.dead == false:
		valueX = sin(time)/10
		valueY = 0
	ICON.material.get_shader_parameter("Dtexture").fill_from = Vector2(
		valueX+0.517,
		valueY+0.162
	)
	ICON.material.set_shader_parameter("val",val)
	ICON.material.set_shader_parameter("Dtexture",from_fill)
	
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	time += delta
	FPS.text = "FPS: "+str(int(1/delta))
	setPivots()
	ICON_VAL(delta)
	ICON_POS(delta)
