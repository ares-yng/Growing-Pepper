extends Area2D

var spriteNode
var highlightNode

var objectInfo = {}
var currentGrowthStage
var isWatered = false #parent (tile) will tell it when it is watered
var isHarvested = false #signal to parent 

#called by parent
func water():
	isWatered = true
func advance():
	#grow if watered
	if isWatered:
		if currentGrowthStage < getGrowthTime():
			currentGrowthStage += 1
		isWatered = false
	spriteNode.frame = getGrowthFrame()
func remove():
	queue_free()

#called by player
func harvestRequest():
	if currentGrowthStage == getGrowthTime():
		return getInputPatternID()
	return 0
func harvest(): 
	#spawn loot on ground
	var sceneItemsNode = get_parent().get_parent().get_parent().get_node("FloorGrid")
	sceneItemsNode.spawnItem(getDroppedItemID(), get_global_position())
	
	currentGrowthStage -= getRegrowthTime()
	if getRegrowthTime() == 0:
		isHarvested = true
	else:
		spriteNode.frame = getGrowthFrame()
		

func highlightOn():
	highlightNode.set_visible(true)
func highlightOff():
	highlightNode.set_visible(false)

func setVariables(givenVars, growthStage = 0, wasWatered = false):
	print("setting plant variables...")
	print(givenVars)
	objectInfo = givenVars
	currentGrowthStage = growthStage
	isWatered = wasWatered
	
	var collisionShape2D = $CollisionShape2D
	collisionShape2D.shape.set_size(Vector2(getWidth(), getHeight()))
	
	spriteNode = $Sprite2D
	var texture = load(str("res://Assets/Ingame/Plants/", getAssetName(), ".png"))
	spriteNode.set_texture(texture)
	spriteNode.set_hframes(getMaxFrame() + 1)
	spriteNode.set_frame(getGrowthFrame())
	
	highlightNode = $Highlight

func getGrowthFrame():
	var maxFrame = getMaxFrame()
	var growthTime = getGrowthTime()
	var frame
	
	if currentGrowthStage == 0:
		frame = 0
	elif currentGrowthStage == growthTime+1:
		frame = maxFrame
	else:
		frame = (maxFrame-1) * currentGrowthStage / growthTime
		if frame == 0:
			frame = 1
		elif frame == maxFrame:
			frame = maxFrame - 1
		else:
			frame += 1
	return frame
func getCurrentGrowthStage():
	return currentGrowthStage
func getHeight():
	match getSizeType():
		"1x1":
			return 16
	return 16
func getWidth():
	match getSizeType():
		"1x1":
			return 16
	return 16

#parameters
func getID():
	return objectInfo["plant_id"]
func getAssetName():
	return objectInfo["ingame_name"]
func getMaxFrame():
	return objectInfo["max_frame"]
func getSizeType():
	return objectInfo["size_type"]
func getGrowthTime():
	return objectInfo["growth_time"]
func getRegrowthTime():
	return objectInfo["regrowth_time"]
func getInputPatternID():
	return objectInfo["input_pattern_id"]
func getDroppedItemID():
	return objectInfo["dropped_item_id"]
