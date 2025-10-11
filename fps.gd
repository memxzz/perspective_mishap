extends Label
func _process(delta: float) -> void:
	text = "fps: "+str(int(1/delta))
