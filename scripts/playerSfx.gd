extends AudioStreamPlayer3D
var plr
var sounds: Dictionary = {
	#sfx
	walk = "res://assets/audio/SFX/walk.mp3",
	jump = "res://assets/audio/SFX/jump.mp3",
}
var musicNode
var options = {
	loop = false,
	bpm = 90,
	bar_beats = 4
}
var currSound = ""
var lastSound = "nul"
func _ready() -> void:
	plr = get_parent()
	for i in sounds.keys(): #convert to stream
		sounds[i] = load(sounds[i])
	var scene = get_tree().current_scene
	
func playSound():
	if currSound == lastSound:return
	lastSound = currSound
	stop()
	if not currSound in sounds:return
	stream = sounds[currSound]
	stream.loop = options.loop
	stream.bpm = options.bpm
	stream.bar_beats = options.bar_beats
	play()
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	playSound()
	options.loop = false
	if plr.playerDirection != Vector3.ZERO and plr.playerStates.inAir == false:
		currSound = "walk"
		options.loop = true
		return
	if plr.velocity.y > 0 and plr.playerStates.inAir == true:
		currSound = "jump"
		return
	currSound = "non"
	options.loop = false
