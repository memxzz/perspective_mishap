extends AnimationPlayer
@onready var timerVar = $Timer
@export var fps:float = 17

func timer() -> void:
	
	timerVar.start()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.callback_mode_process = AnimationPlayer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	timerVar.wait_time = 1/fps
	timerVar.connect("timeout",Callable(self,"timer_timeout"))
	print(self.callback_mode_process)
func timer_timeout():
	pass
	advance(1/fps)
