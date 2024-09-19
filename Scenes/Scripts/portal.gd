extends Node2D

var linkedScene = []

func _ready():
	var arr = name.lstrip("Portal_").split(";")
	linkedScene += [int(arr[0])] #other scene's id
	linkedScene += [int(arr[1])] #portal's child index on the other scene

func setData(saveData):
	saveData["portal_scene_ids"]

func _on_area_entered(area):
	get_parent().get_parent().requestingSceneChange = linkedScene
