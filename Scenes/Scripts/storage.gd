extends Area2D

var data = {}

@onready var Items = preload("res://Scenes/items_resource.gd").new()
@export var collisionSize = Vector2(100, 100)
@export var displayPosition = Vector2(0, 0)

#@onready var closeButton = $Tab
var isOpen = false
var slotNodes = []
@onready var slotsNode = $Slots

func tryToTalk():
	doStorage()
func doStorage(): #opens or closes
	if isOpen:
		slotsNode.set_visible(false)
		slotsNode.process_mode = Node.PROCESS_MODE_DISABLED
		isOpen = false
	else:
		slotsNode.set_visible(true)
		slotsNode.process_mode = Node.PROCESS_MODE_INHERIT
		isOpen = true

func getID():
	return int(name.lstrip("Storage_"))
func getData():
	var saveData = {"player_id": data["player_id"], "storage_id": data["storage_id"]}
	saveData.merge(packData(slotNodes, ["item_id", "quantity"]))
	return saveData
func setData(saveData): 
	data = saveData
	slotsNode.set_visible(false)
	#instantiate all the slots and existing items
	var itemIDs = unpackData(saveData["item_id"])
	var quantities = unpackData(saveData["quantity"])
	for index in itemIDs.size(): #for each item slot, 
		var slot = load("res://Scenes/Prefabs/Slot.tscn").instantiate() #create a slot
		slotsNode.add_child(slot)
		slotNodes += [slot]
		slot.halve()
		slot.changeFrame(2)
		
		if itemIDs[index] != null: #if there is an item in the slot, create an item with its quantity in the slot 
			var item = load("res://Scenes/Prefabs/Item.tscn").instantiate()
			item.setVariables(itemIDs[index], quantities[index])
			slot.putItem(item)
	#rearrange the slots
	setSlotPositions(slotNodes.size())
	#add a UI collision
	slotsNode.process_mode = Node.PROCESS_MODE_DISABLED
func setSlotPositions(numSlots, numColumns = 4, margins = Vector2(20, 20)): #rearrange the slot children and slots node
	#slots node position
	var relativePos = Vector2(0, -100)
	slotsNode.global_position = slotsNode.global_position + relativePos
	
	#slot children
	var slotBounds = Vector2(collisionSize.x - margins.x, collisionSize.y - margins.y)
	var numRows = numSlots/numColumns
	
	var columnWidth = slotBounds.x / numColumns
	var rowHeight = columnWidth#inventorySize.y / numRows
	
	for slotNum in numSlots:
		var row = slotNum / numRows + 1
		var column = slotNum % numColumns + 1
		
		var x = column*columnWidth - columnWidth/2 - slotBounds.x/2
		var y = row*rowHeight - rowHeight/2 - slotBounds.y/2
		
		var newPosition = Vector2(x, y)
		slotNodes[slotNum].set_position(newPosition)
func setSpritesheet(filename):
	var spritesheet = load(str("res://Assets/Ingame/Environment/", filename, ".tres"))
	$AnimatedSprite2D.set_sprite_frames(spritesheet)

func packData(nodeArr, parameters, delimiter = ";"): #returns a dictionary based on parameters
	#initialize dictionary
	var data = {} 
	for parameter in parameters: 
		data[parameter] = ""
	
	#add data
	for node in nodeArr: #for each node,
		var childData = node.getData() #get data.
		for parameter in parameters: #then for each parameter,
			if childData != null: #if there is data, 
				data[parameter] += str(childData[parameter]) #concat its data to all the data
			data[parameter] += delimiter #else just add the delimiter
	
	#remove extra delimiter from each parameter
	for parameter in parameters: 
		data[parameter] = data[parameter].left(-1)
	
	return data
func unpackData(str, delimiter = ";"): #returns an array given a string
	var packedArr = str.split(delimiter)
	var arr = []
	#convert the packed array to an int array
	for i in packedArr.size():
		if packedArr[i] == "": 
			arr += [null] #empty array slot
		else:
			arr += [int(packedArr[i])] #int slot
	return arr
