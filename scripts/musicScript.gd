extends AudioStreamPlayer3D
var actualsong = 0
var playable:bool = false
var plr
var ogVolume:float = 0
var ogPitch:float = 1
var setVolume:float = ogVolume
var setPitch:float = ogPitch
var transitionSpeed:float = .5
var songs = {
	opening = "",
	regular = "",
}
func start(array):
	playable = false
	actualsong = 0
	stop()
	await get_tree().create_timer(1).timeout
	songs.opening = load(array[0])
	songs.regular = load(array[1])
	playable = true 
func volumeNpitch(delta):
	volume_db = lerpf(volume_db,setVolume,delta*transitionSpeed)
	pitch_scale = lerpf(pitch_scale,setPitch,delta*transitionSpeed)
func _process(delta: float) -> void:
	if plr == null:
		plr = GlobalVars.vars.plr
		return
	global_position = plr.camera.global_position
	volumeNpitch(delta)
	if playable == false:return
	if playing == true:return
	actualsong += 1

	if actualsong == 1:
		stream = songs.opening
	elif actualsong >= 2:
		stream = songs.regular
	#play()
