extends Node2D
@onready var db = load("res://Scenes/database_resource.gd").new()

var playerDirection = "Down" #told by parent
var inputsDisplayNode #assigned by parent
var offset = {"Left": [-5, 0], "Right": [5, 0], "Up": [0, -5], "Down": [0, 5]}

var nearbyLeftObjects = []
var nearbyRightObjects = []
var nearbyUpObjects = []
var nearbyDownObjects = []
var lastClosestObject
var objectBeingHarvested

var harvestInputs
var currentInput

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("testbutton1"):
		pass
	
	if lastClosestObject != null || nearbyLeftObjects != [] || nearbyRightObjects != [] || nearbyUpObjects != [] || nearbyDownObjects != []:
		match playerDirection:
			"Left":
				focusClosestObject(nearbyLeftObjects)
			"Right":
				focusClosestObject(nearbyRightObjects)
			"Up":
				focusClosestObject(nearbyUpObjects)
			"Down":
				focusClosestObject(nearbyDownObjects)
	#if lastClosestObject != null && nearbyLeftObjects == [] && nearbyRightObjects == [] && nearbyUpObjects == [] && nearbyDownObjects == []:
	#	focusClosestObject([])
	
	if objectBeingHarvested != null:
		if lastClosestObject != objectBeingHarvested:
			endHarvest()

func newPlayerDirection(direction):
	playerDirection = direction

func checkInput(direction):
	if direction == harvestInputs[currentInput]:
		print("successful input")
		inputsDisplayNode.updateDisplayedInput(currentInput, true)
		currentInput += 1
		if currentInput > harvestInputs.size()-1:
			successfulHarvest()
	else:
		endHarvest()
		
func successfulHarvest():
	var isObjectRemoved = objectBeingHarvested["node"].harvest()
	if isObjectRemoved:
		nearbyLeftObjects = removeObject(nearbyLeftObjects, objectBeingHarvested["node"])
		nearbyRightObjects = removeObject(nearbyRightObjects, objectBeingHarvested["node"])
		nearbyUpObjects = removeObject(nearbyUpObjects, objectBeingHarvested["node"])
		nearbyDownObjects = removeObject(nearbyDownObjects, objectBeingHarvested["node"])
		lastClosestObject = null
	endHarvest()
func endHarvest():
	print("harvest ended.")
	objectBeingHarvested = null
	inputsDisplayNode.hideInputs()

func startHarvestingObject():
	#check if the closest object exists and is available to harvest
	var closestObject = lastClosestObject
	if closestObject != null:
		var harvestPatternId = closestObject["node"].harvestRequest()
		if harvestPatternId != 0:
			var harvestPattern = db.getDictionary("parameters", "input_patterns", "*", "input_pattern_id", harvestPatternId)
			var weights = db.getQuery("parameters", "weighted_inputs", "*")
			harvestInputs = inputsDisplayNode.newWeightedInputs(harvestPattern, weights)
			objectBeingHarvested = closestObject
			currentInput = 0

#func clickHarvest():
	#var mousePos = get_global_mouse_position() 
	#params.set_position(mousePos)
	#var query = space.intersect_point(params)
	#if query:
		##cycle through colliders hit by the query
		#for i in query.size():
			#var obj = query[i]["collider"]
			#print("Hit at point: ", obj.name)
			##check if the object has the required property
			#if obj.has_method("getID"):
				#var target_id = obj.getID()
				#print("it has a target_id: ", target_id)
				##check if the object is in range to be interacted with
				#var matchingObject = nearbyObjects.filter(func(r):return r["unique_id"]==obj.get_instance_id())
				#print(matchingObject)
				#if !matchingObject.is_empty():
					##run harvest pattern retrieval
					#print("nearby and clicked. retrieving harvest pattern...")
					#var harvestInputId = matchingObject[0]["harvest_pattern_id"]
					#harvestInputs = create_weightedInputs(harvestInputId)
					##display harvest pattern on screen
					#displayNewInputs(harvestInputs)
					#listeningForInputs = matchingObject[0]["unique_id"]
					#break
				#else:
					#print("object not in range")
			##overly cautious: makes sure the inputs do not appear or stay 
			#closeInputs()
	#else:
		#print("clicked")
		#closeInputs()

func focusClosestObject(nearbyObjects):
	if nearbyObjects == []:
		if lastClosestObject != null && lastClosestObject["node"] != null:
			lastClosestObject["node"].highlightOff()
			lastClosestObject = null
			return
	var closestObject = getClosestObject(nearbyObjects)
	if lastClosestObject != closestObject:
		if lastClosestObject != null && lastClosestObject["node"] != null:
			lastClosestObject["node"].highlightOff()
		if closestObject != null && closestObject["node"] != null:
			closestObject["node"].highlightOn()
		lastClosestObject = closestObject
func getClosestObject(nearbyObjects):
	var closestObject
	var closestObjectDistance = 1000
	for object in nearbyObjects:
		var distance = calcDistance(object)
		if distance < closestObjectDistance:
			closestObject = object
			closestObjectDistance = distance
	return closestObject
func calcDistance(object):
	var offsetPos = self.global_position
	offsetPos.x += offset[playerDirection][0]
	offsetPos.y += offset[playerDirection][1]
	return offsetPos.distance_to(object["node"].global_position)

func addObject(nearbyObjects, area):
	nearbyObjects += [{"node": area, "unique_id": area.get_instance_id(), "object_id": area.getID(), "dropped_item_id": area.getDroppedItemID()}]
	return nearbyObjects
func removeObject(nearbyObjects, area):
	var entryToRemove = nearbyObjects.filter(func(r):return r["unique_id"]==area.get_instance_id())
	nearbyObjects.erase(entryToRemove[0])
	#if harvesting this object, close the inputs
	if objectBeingHarvested != null && objectBeingHarvested["unique_id"] == entryToRemove[0]["unique_id"]:
		endHarvest()
	return nearbyObjects

#child signals
func _on_harvest_hitbox_left_area_entered(area):
	nearbyLeftObjects = addObject(nearbyLeftObjects, area)
func _on_harvest_hitbox_left_area_exited(area):
	nearbyLeftObjects = removeObject(nearbyLeftObjects, area)

func _on_harvest_hitbox_right_area_entered(area):
	nearbyRightObjects = addObject(nearbyRightObjects, area)
func _on_harvest_hitbox_right_area_exited(area):
	nearbyRightObjects = removeObject(nearbyRightObjects, area)

func _on_harvest_hitbox_up_area_entered(area):
	nearbyUpObjects = addObject(nearbyUpObjects, area)
func _on_harvest_hitbox_up_area_exited(area):
	nearbyUpObjects = removeObject(nearbyUpObjects, area)

func _on_harvest_hitbox_down_area_entered(area):
	nearbyDownObjects = addObject(nearbyDownObjects, area)
func _on_harvest_hitbox_down_area_exited(area):
	nearbyDownObjects = removeObject(nearbyDownObjects, area)
