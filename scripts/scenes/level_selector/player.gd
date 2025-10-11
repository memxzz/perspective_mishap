extends Node3D
@onready var scene = get_parent()
@onready var places = scene.get_node("places")
var placesList: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in places.get_children():
		placesList[i.name.to_int()] = i
	print(placesList)
func move(direction):
	var place = places.get_node(str(scene.actual_place))
	if place[direction] != null:
		scene.actual_place = place[direction].name.to_int()
func select():
	var place = places.get_node(str(scene.actual_place))
	if not place.haveInfo:return
	get_tree().change_scene_to_packed(place.level)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_right"):move("right")
	if event.is_action_pressed("move_left"):move("left")
	if event.is_action_pressed("move_up"):move("up")
	if event.is_action_pressed("move_down"):move("down")
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			select()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if placesList.is_empty():return
	var place = places.get_node(str(scene.actual_place))
	global_position = lerp(
		global_position,
		place.global_position,
		delta*5
		)
