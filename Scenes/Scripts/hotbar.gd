extends Sprite2D
@onready var Items = preload("res://Scenes/items_resource.gd").new()

var slotNodes = []
var currentlySelectedSlot
var updateHand = false #signal to player
var newSelection #signal to player

# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in $Slots.get_children(): 
		slotNodes += [slot]
		slot.changeFrame(2)
		slot.isHotbarSlot = true
	var numSlots = slotNodes.size()
	setSlotPositions(slotNodes, numSlots)
	
	var keyNodes = []
	for key in $Keys.get_children():
		keyNodes += [key]
	setSlotPositions(keyNodes, numSlots, Vector2(-18, -18))
	
	currentlySelectedSlot = 0
	slotNodes[currentlySelectedSlot].changeFrame(4)

func _process(delta):
	for i in slotNodes.size():
		if slotNodes[i].isClicked:
			switchToSlot(i)
			slotNodes[i].isClicked = false
			break
	for i in slotNodes.size():
		if slotNodes[i].updateItem:
			if currentlySelectedSlot == i:
				newSelection = slotNodes[i].newItem
				updateHand = true
			slotNodes[i].newItem = null
			slotNodes[i].updateItem = false
			break

func useItem(quantity):
	slotNodes[currentlySelectedSlot].useItem(quantity)
func getItemID():
	return slotNodes[currentlySelectedSlot].getItemID()
func getAction():
	return slotNodes[currentlySelectedSlot].getAction()
func getChargeLeftActionID():
	return slotNodes[currentlySelectedSlot].getChargeLeftActionID()
func getChargeRightActionID():
	return slotNodes[currentlySelectedSlot].getChargeRightActionID()
func switchToSlot(i):
	slotNodes[currentlySelectedSlot].changeFrameRelative(-2)
	currentlySelectedSlot = i
	slotNodes[currentlySelectedSlot].changeFrameRelative(2)
	updateHand = true
	newSelection = getItemID()

func setSlotPositions(nodes, numSlots, posOffset = Vector2(0, 0)):
	var bounds = Vector2(48, 540-220)
	var margins = Vector2(16, 64)
	
	var rowHeight = (bounds.y - margins.y) / numSlots
	var x = bounds.x/2
	var y = margins.y/2 + rowHeight/2
	
	for node in nodes:
		var pos = Vector2(x + posOffset.x, y + posOffset.y)
		node.set_position(pos)
		y += rowHeight

func setHotbarData(saveFile):
	var db = load("res://Scenes/database_resource.gd").new()
	var ids = Items.convertToArray(saveFile["hotbar_item_ids"])
	var quantities = Items.convertToArray(saveFile["hotbar_item_quantities"])
	
	for i in slotNodes.size():
		if ids[i] != 0:
			var itemData = db.getDictionary("parameters", "item_data", "*", "item_id", ids[i])
			var item = load("res://Scenes/Prefabs/Item.tscn").instantiate()
			item.setVariables(ids[i], quantities[i])
			slotNodes[i].putItem(item)
	
	switchToSlot(saveFile["hotkey_index_selected"])
func getHotbarData():
	var hotbarData = {"hotkey_index_selected": currentlySelectedSlot}
	
	var itemData = Items.convertToData(slotNodes)
	hotbarData["hotbar_item_ids"] = itemData["ids"]
	hotbarData["hotbar_item_quantities"] = itemData["quantities"]
	
	return hotbarData
