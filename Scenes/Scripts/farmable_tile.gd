extends Area2D

var data = {"item_id": 0, "tile_growth_stage": 0, "tile_is_watered": 0}

var plantNode = null
@onready var tileNode = $Sprite2D
@onready var tempNode = $Label

func _process(delta):
	if plantNode != null:
		if plantNode.isHarvested:
			plantNode.remove()
			plantNode = null
			data["item_id"] = 0
			data["tile_growth_stage"] = 0
			tempNode.text = str(data["tile_growth_stage"])

#called by player
func interact(action, item_id = 1): #returns true if item is consumed
	match action:
		"Plant":
			if !plantNode:
				print("planting " + str(item_id))
				spawnPlant(item_id)
				return true
		"Water":
			if !data["tile_is_watered"]:
				tileNode.set_frame(1)
				if plantNode != null:
					plantNode.water()
					#todo later when different size tiles are implemented, do something?
				data["tile_is_watered"] = 1
		"Hoe":
			print("use hoe")
		"Sickle":
			if plantNode:
				print("cutting down plant")
		"Chop":
			print("use axe")
		"Hammer":
			print("use hammer")

func advance():
	if data["tile_is_watered"]:
		tileNode.set_frame(0)
		data["tile_is_watered"] = 0

func getData():
	if data["item_id"] != 0:
		data["tile_growth_stage"] = plantNode.getCurrentGrowthStage()
	var saveData = {"plant_id": data["item_id"], "tile_growth_stage": data["tile_growth_stage"], "tile_is_watered": data["tile_is_watered"]}
	return saveData
func setData(saveData): #tile is set by scene when the scene is loaded
	data = saveData
	data["item_id"] = saveData["plant_id"]
	
	if data["item_id"] != 0:
		spawnPlant(data["item_id"], data["tile_growth_stage"], data["tile_is_watered"])
	
	if data["tile_is_watered"]:
		tileNode.set_frame(1)
	tempNode.text = str(data["tile_growth_stage"])
	print(str(data["item_id"]) + ", " + str(data["tile_growth_stage"]))

#plant is spawned when setData() is called or when player plants a plant
func spawnPlant(id, growthStage = 0, wasWatered = false):
	data["item_id"] = id
		
	plantNode = load("res://Scenes/Prefabs/Plant.tscn").instantiate()
	var db = load("res://Scenes/database_resource.gd").new()
	var plantData = db.getDictionary("parameters", "plant_data", "*", "item_id", id)
	plantNode.setVariables(plantData, growthStage, wasWatered)
	add_child(plantNode)

