extends Area2D
@onready var db = preload("res://Scenes/database_resource.gd").new()

var linkedScene = []

func _ready():
	var arr = name.lstrip("Building_").split(";")
	var buildingID = int(arr[0]) #building id
	linkedScene += [int(arr[1])] #other scene's id
	linkedScene += [int(arr[2])] #portal's child index on the other scene
	
	var loadData = db.getDictionary("parameters", "building_data", "*", "building_id", buildingID)
	var sprite = load(str("res://Assets/Ingame/Environment/", loadData["ingame_filename"], ".png"))
	$Door/Sprite2D.set_texture(sprite)

func enter():
	get_parent().get_parent().requestingSceneChange = linkedScene
