extends VBoxContainer

var sceneNode

var playNode
var optionsNode

var focusedNode
var focusIndicator
var focusIndicatorPos
var focusIndicatorPosOffset = Vector2(-30, 22)

# Called when the node enters the scene tree for the first time.
func _ready():
	playNode = $Play
	optionsNode = $Options
	focusIndicator = $FocusIndicator
	
	playNode.grab_focus()
	focusedNode = playNode
	
	set_focusIndicatorPos(focusedNode)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if playNode.has_focus() && focusedNode != playNode:
		focusedNode = playNode
		set_focusIndicatorPos(focusedNode)
		print("focusing on play child")
	if optionsNode.has_focus() && focusedNode != optionsNode:
		focusedNode = optionsNode
		set_focusIndicatorPos(focusedNode)
		print("focusing on options child")
		
	if Input.is_action_just_pressed("ui_accept"):
		match focusedNode:
			playNode:
				sceneNode.changeRight("PlayerSelect")
			optionsNode:
				sceneNode.changeRight("Options")

func set_focusIndicatorPos(child):
	focusIndicatorPos = child.get_global_position()
	focusIndicatorPos.x += focusIndicatorPosOffset.x
	focusIndicatorPos.y += focusIndicatorPosOffset.y
	focusIndicator.set_global_position(focusIndicatorPos)

func _on_area_2d_mouse_entered_play():
	playNode.grab_focus()
func _on_area_2d_mouse_entered_options():
	optionsNode.grab_focus()

func _on_area_2d_input_event_play(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.changeRight("PlayerSelect")
func _on_area_2d_input_event_options(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.changeRight("Options")

