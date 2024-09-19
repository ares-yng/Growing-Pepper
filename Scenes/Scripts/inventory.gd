extends Sprite2D
@onready var Items = preload("res://Scenes/items_resource.gd").new()

@onready var inventoryTabNode = $Tab
var hotbarNode
var isInventoryOpen = true
var slotNodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in $Slots.get_children(): 
		slotNodes += [slot]
	doInventory()

func doInventory():
	var invSize = Vector2(160, 540)
	var invPos = Vector2(272, -270)
	var tabSize = Vector2(64, 32)
	var tabPos = Vector2(invSize.x - tabSize.x/4, tabSize.y/2)
	
	if isInventoryOpen:
		invPos.y += invSize.y
		tabPos.y -= tabSize.y
		
		inventoryTabNode.set_rotation_degrees(0)
		inventoryTabNode.set_position(tabPos)
		
		set_position(invPos)
		isInventoryOpen = false
	else:
		inventoryTabNode.set_rotation_degrees(180)
		inventoryTabNode.set_position(tabPos)
		
		set_position(invPos)
		isInventoryOpen = true

func putItem(item):
	var hotbarSlotNodes = hotbarNode.slotNodes
	#loop until item is fully put away
	while item:
		#find the first available spot to put the item away. check hotbar first
		var space = getSpace(hotbarSlotNodes, item.getItemID(), item.getStackMax(), item.getQuantity())
		if space != null:
			item = hotbarSlotNodes[space].putItem(item)
		else:
			space = getSpace(slotNodes, item.getItemID(), item.getStackMax(), item.getQuantity())
			#if there is no space, give the item back
			if space != null:
				item = slotNodes[space].putItem(item)
			else:
				return item
		#if the item was partially put away, the loop activates

func getSpace(nodes, matchID = -1, stackMax = 0, quantity = 0): #returns first non-full matching space or first empty space. returns null if no match and no empty
	var emptySlot = null
	for i in nodes.size():
		var itemData = nodes[i].getData()
		if emptySlot == null && !itemData:
			emptySlot = i
		if matchID != -1 && stackMax != 1 && itemData:
			if itemData["item_id"] == matchID && itemData["quantity"]+quantity < stackMax:
				return i
	return emptySlot

func setInventoryData(saveFile):
	var db = load("res://Scenes/database_resource.gd").new()
	var ids = Items.convertToArray(saveFile["inventory_item_ids"])
	var quantities = Items.convertToArray(saveFile["inventory_item_quantities"])
	
	for i in slotNodes.size():
		setSlotPosition(slotNodes[i], i)
		if i < saveFile["inventory_slots_unlocked"]:
			if ids[i] != 0:
				var itemData = db.getDictionary("parameters", "item_data", "*", "item_id", ids[i])
				var item = load("res://Scenes/Prefabs/Item.tscn").instantiate()
				item.setVariables(ids[i], quantities[i])
				slotNodes[i].putItem(item)
			slotNodes[i].changeFrame(2)
func getInventoryData():
	var inventoryData = {"inventory_max_slots": slotNodes.size()}
	var countSlotsUnlocked = 0
	for i in inventoryData["inventory_max_slots"]:
		if slotNodes[i].getState():
			countSlotsUnlocked += 1
	inventoryData["inventory_slots_unlocked"] = countSlotsUnlocked
	
	var itemData = Items.convertToData(slotNodes)
	inventoryData["inventory_item_ids"] = itemData["ids"]
	inventoryData["inventory_item_quantities"] = itemData["quantities"]
	
	return inventoryData

func setSlotPosition(node, slotNum):
	var invSize = Vector2(160, 540)
	
	var maxSlots = 9
	var numColumns = 3
	var numRows = maxSlots/numColumns
	
	var margins = Vector2(40, 60)
	var slotBounds = Vector2(invSize.x - margins.x, invSize.y - margins.y)
	
	var columnWidth = slotBounds.x / numColumns
	var rowHeight = columnWidth#inventorySize.y / numRows
	
	var row = slotNum / numRows + 1
	var column = slotNum % numColumns + 1
	
	var x = column*columnWidth - columnWidth/2 + margins.x/2
	var y = row*rowHeight - rowHeight/2 + margins.y/2
	var newPosition = Vector2(x, y)
	
	node.set_position(newPosition)
