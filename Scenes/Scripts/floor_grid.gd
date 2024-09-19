extends TileMap

var isFloorVisible = false
var invisibleTileset = "res://Assets/UI/invisible_floorGrid.tres"
var visibleTileset = "res://Assets/UI/visible_floorGrid.tres"

var tileSize = 32
var allTiles = []
var occupiedTiles = []
var itemsOnFloor = []

# Called when the node enters the scene tree for the first time.
func _ready():
	allTiles = get_used_cells(-1)
	set_tileset(load(invisibleTileset))

func _process(delta):
	if Input.is_action_just_pressed("testbutton1"):
		if isFloorVisible:
			set_tileset(load(invisibleTileset))
			isFloorVisible = false
		else:
			set_tileset(load(visibleTileset))
			isFloorVisible = true

func pullItem(item): 
	var index = itemsOnFloor.find(item)
	remove_child(itemsOnFloor[index])
	occupiedTiles.remove_at(index)
	itemsOnFloor.remove_at(index)
func putItem(item, pos): #returns true if item was put
	var tilePos = Vector2i(pos/tileSize)
	var index = allTiles.find(tilePos)
	#checks neighbors too
	if index != -1:
		if occupiedTiles.has(tilePos):
			print("tile was full")
			return false
		else:
			var actualPos = tilePos * tileSize
			actualPos.x += tileSize/2
			actualPos.y += tileSize/2
			
			item.set_global_position(actualPos)
			add_child(item)
			itemsOnFloor.append(item)
			occupiedTiles.append(tilePos)
			return true
	else:
		print("not on grid")
		return false
	return item

#items are spawned as loot or when loading
func spawnItem(item_id, pos, quantity = 1):
	var item = load("res://Scenes/Prefabs/Item.tscn").instantiate()
	item.setVariables(item_id, quantity)
	item = putItem(item, pos)
	if typeof(item) != typeof(true):
		item.queue_free()

func getData(parameters):
	var delimiter = ";"
	#initialize dictionary
	var saveData = {}
	for i in parameters.size():
		saveData[parameters[i]] = ""
	
	for i in itemsOnFloor.size(): #for each item on the floor add its data
		var itemData = itemsOnFloor[i].getData()
		saveData[parameters[0]] += str(itemData[parameters[0]], delimiter)
		saveData[parameters[1]] += str(itemData[parameters[1]], delimiter)
		saveData[parameters[2]] += str(occupiedTiles[i], delimiter)
	
	for i in parameters.size(): #remove extra delimiter from each parameter
		saveData[parameters[i]] = saveData[parameters[i]].left(-1)
	
	return saveData
func setData(saveData, parameters):
	#no data to set
	if saveData[parameters[0]] == "":
		return
	
	var delimiter = ";"
	var saveDataCopy = {}
	for i in parameters.size():
		saveDataCopy[parameters[i]] = saveData[parameters[i]].split(delimiter) 
	
	for i in saveDataCopy[parameters[0]].size():
		var item_id = int(saveDataCopy[parameters[0]][i])
		var quantity = int(saveDataCopy[parameters[1]][i])
		var stringVector = saveDataCopy[parameters[2]][i].split(",")
		var pos = Vector2i(stringVector[0].to_int(), stringVector[1].to_int())
		spawnItem(item_id, pos*tileSize, quantity) #item is added to data
