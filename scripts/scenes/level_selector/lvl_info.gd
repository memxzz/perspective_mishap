extends Panel
#nodes:
@onready var icon = $icon
@onready var textName = $lvlName
@onready var textDesc = $description
var Main
func update():
	Main = get_tree().current_scene
	var actualPlace = Main.places.get_node(str(Main.actual_place))
	visible = actualPlace.haveInfo
	if not visible:return
	var iconTexture = actualPlace.levelIcon
	textName.text = actualPlace.levelName
	textDesc.text = actualPlace.description
	var styleBox = StyleBoxTexture.new()
	styleBox.texture = load(iconTexture)
	icon.add_theme_stylebox_override("panel",styleBox)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
var lastPlace = -1
func _process(delta: float) -> void:
	if Main == null:return
	if lastPlace != Main.actual_place:
		lastPlace = Main.actual_place
		update()
