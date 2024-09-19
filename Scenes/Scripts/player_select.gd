extends VBoxContainer

var sceneNode

func _on_player0_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.selectPlayer(0)
func _on_player1_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.selectPlayer(1)
func _on_player2_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.selectPlayer(2)

func _on_delete_player0_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.changeRight("DeletePlayer", 0)
func _on_delete_player1_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.changeRight("DeletePlayer", 1)
func _on_delete_player2_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		sceneNode.changeRight("DeletePlayer", 2)
