extends VBoxContainer

var sceneNode
var task
var pendingPlayerID

func _on_accept_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.accept(task, pendingPlayerID)
func _on_decline_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.decline(task)
