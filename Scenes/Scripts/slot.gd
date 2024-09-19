extends Area2D

@onready var spriteNode = $Sprite2D
var itemNode
var updateItem = false #signal to parent
var newItem = null #signal to parent
var isClicked = false #signal to parent
var isHotbarSlot = false #assigned by parent

func click(hasItemInMouse):
	isClicked = true
	if itemNode != null:
		if isHotbarSlot && (spriteNode.frame == 2 || spriteNode.frame == 3) && !hasItemInMouse:
			return
		return itemNode
	else:
		return "empty slot"

func pullItem(_item):
	itemNode.set_collision_layer_value(5, true) 
	remove_child(itemNode)
	itemNode = null
	if isHotbarSlot:
		updateItem = true
		newItem = null
func putItem(item): #returns item node if there are leftovers, or null if it was completed successfully
	var returnValue = null
	var otherParent = item.get_parent()
	if otherParent:
		if itemNode:
			#item has an existing parent and this slot is occupied with the same item - add quantity then return leftovers/delete from other slot
			if item.getItemID() == itemNode.getItemID():
				var leftover = itemNode.addQuantity(item.getQuantity())
				if !leftover:
					otherParent.pullItem(item)
					item.queue_free()
					return
				else:
					item.setQuantity(leftover)
					item.set_collision_layer_value(5, false) 
					return item
			#item has an existing parent and this slot is occupied with a different item - swap and put item in
			else:
				var tempItem = itemNode
				pullItem(itemNode)
				otherParent.pullItem(item)
				otherParent.putItem(tempItem)
		#item has an existing parent and this slot is empty - remove from parent and put item in
		else:
			otherParent.pullItem(item)
	#item is from no parent - this slot is empty so put item in
	add_child(item)
	item.set_collision_layer_value(5, false) 
	item.set_position(Vector2(0, 0))
	itemNode = item
	if isHotbarSlot:
		updateItem = true
		newItem = getItemID() #refreshes what the player is holding

func changeFrame(index):
	spriteNode.frame = index
func changeFrameRelative(index):
	spriteNode.frame += index

func halve():
	scale.x = .5
	scale.y = .5

func useItem(quantity = 1):
	if itemNode.useItem(quantity):
		itemNode.queue_free()
		itemNode = null
func getItemID():
	if itemNode:
		return itemNode.getItemID()
func getAction():
	if itemNode:
		return itemNode.getAction()
func getChargeLeftActionID():
	if itemNode:
		return itemNode.getChargeLeftActionID()
func getChargeRightActionID():
	if itemNode:
		return itemNode.getChargeRightActionID()
func getState():
	if spriteNode.frame <= 1:
		return false
	return true
func getData():
	if itemNode:
		return itemNode.getData()

func _on_area_2d_mouse_entered():
	if spriteNode.frame >= 2:
		spriteNode.frame += 1
		if spriteNode.frame % 2 == 0:
			spriteNode.frame -= 1

func _on_area_2d_mouse_exited():
	if spriteNode.frame >= 2:
		spriteNode.frame -= 1
		if spriteNode.frame % 2 == 1:
			spriteNode.frame += 1
