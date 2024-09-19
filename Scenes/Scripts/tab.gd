extends Area2D

func click(_hasItemInMouse):
	get_parent().doInventory()

func _on_tab_mouse_entered():
	get_child(0).set_frame(1)

func _on_tab_mouse_exited():
	get_child(0).set_frame(0)
