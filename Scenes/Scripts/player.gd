extends CharacterBody2D
@onready var db = load("res://Scenes/database_resource.gd").new()

#vars for game controller
var isRequestingSave = false
var isRequestingLoad = false
var playerID
var playerName
var currentSpecialDialogueCheckpoint #updated by the game controller when conditions are met
var keybinds = {"harvest_pickup_enter": "ui_up", "use": "ui_down", "click_move": "LMB", "inventory": "shift", "talk": "RMB", "dialogue": "ui_right",
				"hotkey1": "hotkey1", "hotkey2": "hotkey2", "hotkey3": "hotkey3", "hotkey4": "hotkey4", "hotkey5": "hotkey5", 
				"save": "o", "load": "p", "testbutton1": "testbutton1", "testbutton2": "testbutton2", "testbutton3": "testbutton3"}
var isTouchingQuestRequirements = false

#systems
@onready var controlsNode = $CanvasLayer/Controls
@onready var controlsLabelNodes = {"Up": $CanvasLayer/Controls/Up/UpLabel, "Down": $CanvasLayer/Controls/Down/DownLabel, "Left": $CanvasLayer/Controls/Left/LeftLabel, "Right": $CanvasLayer/Controls/Right/RightLabel}
@onready var inventoryNode = $Inventory
var isInventoryOpen = false
@onready var inputsSystemNode = $InputsSystem
var isCharging = {"function": "charge", "chargeAction": "hit", "chargeActionID": null, "useReleased": true}
@onready var hotbarNode = $Hotbar
@onready var reachNode = $Reach
@onready var itemInMouseNode = $ItemInMouse
var updateItemInMouse = false
var itemInMouse
var isHolding
#signal readyToInput

var nearbyNPCs = []
var isDialogueOpen = false
var isRequestingDialogue = false #signal to game controller to scene

#movement
var isMoving = false
var positions = {"targetPoint": Vector2(0,0), "targetPos": Vector2(0,0), "last": Vector2(0,0), "current": Vector2(0,0)}
var speed = 220
var mouseParams
var mouseSpace
var playerDirection = "Down"
@onready var animPlayer = $BodySprite/AnimationPlayer

#hand
@onready var stats = $Stats
@onready var hand = $HandEquip
@onready var handAnimPlayer = $HandEquip.get_child(0).get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	mouseSpace = get_world_2d().get_direct_space_state()
	mouseParams = PhysicsPointQueryParameters2D.new()
	mouseParams.set_collide_with_areas(true)
	
	inventoryNode.hotbarNode = hotbarNode
	inputsSystemNode.playerNode = self

func _physics_process(delta):
	#moving
	#if harvesting or action animation, pass
	if position.distance_to(positions["targetPos"]) > 2:
		velocity = position.direction_to(positions["targetPos"]) * speed
		move_and_slide()
		isMoving = true
		#track movement
		positions["last"] = positions["current"]
		positions["current"] = position
	#if movement was negligible or if target is reached, stop trying to move
	if isMoving && (positions["current"].distance_to(positions["last"]) < .5 || position.distance_to(positions["targetPos"]) <= 2):
		positions["targetPos"] = position
		isMoving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed(keybinds["use"]) || inputsSystemNode.inputsTarget:
		speed = 110
	elif speed == 110:
		speed = 220
	
	if Input.is_action_just_pressed(keybinds["inventory"]):
		inventoryNode.doInventory()
	
	if updateItemInMouse:
		var texture = null
		if itemInMouse:
			texture = itemInMouse.getTexture()
		itemInMouseNode.set_texture(texture)
		updateItemInMouse = false
	if itemInMouse:
		itemInMouseNode.set_global_position(get_global_mouse_position())
	
	if hotbarNode.updateHand: #change what player is holding
		if hotbarNode.newSelection: 
			var hotbarItem = db.getDictionary("parameters", "item_data", "*", "item_id", hotbarNode.newSelection)
			if hotbarItem["ingame_filename"] != null: #if there is an item and it has a hand animation
				var animSpr = hand.get_child(0)
				if animSpr.get_sprite_frames().get_name() != hotbarItem["ingame_filename"]:
					var reso = load(str("res://Assets/Ingame/", hotbarItem["ingame_path"], "/", hotbarItem["ingame_filename"], ".tres"))
					animSpr.set_sprite_frames(reso)
				hand.set_visible(true)
			else: #there is an item but it doesn't have a hand animation
				hand.set_visible(false)
		else: #if there isn't an item being held
			hand.set_visible(false)
		hotbarNode.updateHand = false
		hotbarNode.newSelection = null
	
	turnPlayer(angleToDirection(global_position.angle_to_point(get_global_mouse_position())))
	
	if Input.is_action_just_pressed(keybinds["click_move"]):
		if !isDialogueOpen:
			if mouseClicked(32, get_global_mouse_position(), "click"): 
				pass
			elif itemInMouse: #drop item in mouse
				#free the item from the tree
				var itemParent = itemInMouse.get_parent()
				itemParent.pullItem(itemInMouse) 
				var sceneItemsNode = get_parent().get_node("Scene").get_node("FloorGrid")
				#try putting item on ground
				if !sceneItemsNode.putItem(itemInMouse, global_position): #if it did not work, 
					itemParent.putItem(itemInMouse) #put item back in tree
				else: #else it did work,
					itemInMouse = null #remove from player
					updateItemInMouse = true
					if itemParent.get_parent().get_parent().name == "Hotbar":
						hand.set_visible(false)
			else:
				if inputsSystemNode.inputsTarget && inputsSystemNode.inputsTarget != self:
					inputsSystemNode.endInputs()
				
				positions["targetPoint"] = get_global_mouse_position()
				#actual player position will be offset depending on intersecting face
				#compare the angle between (player and targetPoint) and (targetPoint and corners) to determine the intersecting face
				var playerToPoint = positions["targetPoint"].angle_to_point(position)
				if abs(playerToPoint - PI) < 0.0001: #correct floating point error for player directly left of targetPoint
					playerToPoint = PI
				if playerToPoint < 0: #convert negative angle into positive angle
					playerToPoint += 2*PI
				
				var corners = reachNode.getTileCorners(positions["targetPoint"])
				var cornerAngles = []
				for i in 4: #get angle from targetPoint to each corner
					cornerAngles += [positions["targetPoint"].angle_to_point(corners[i])]
					if cornerAngles[i] < 0: #convert negative angle into positive angle
						cornerAngles[i] += 2*PI
				for i in 3: #make sure the angles produce 4 distinct sections
					while cornerAngles[i] >= cornerAngles[i+1]:
						cornerAngles[i+1] += PI
				var side = 3
				for i in 4: #figure out which section the playerToPoint angle is in 
					if cornerAngles[i] < playerToPoint:
						side = i
				var reach = 16
				var offset
				match side: #add the offset for the player's reach to be in the tile
					0: #bottom face
						offset = Vector2(0, reach)
					1: #left face
						offset = Vector2(-reach, 0)
					2: #top face
						offset = Vector2(0, -reach)
					3: #right face
						offset = Vector2(reach, 0)
				positions["targetPos"] = positions["targetPoint"] + offset
		
	if isDialogueOpen:
		controlsLabelNodes["Up"].text = "---"
		controlsLabelNodes["Down"].text = "---"
		controlsLabelNodes["Left"].text = "---"
		controlsLabelNodes["Right"].text = "Speak"
		if Input.is_action_just_pressed(keybinds["dialogue"]):
			isRequestingDialogue = true
	elif inputsSystemNode.inputsTarget:
		#failure: half energy cost, 25% chance to bungle resources
		#success: full energy cost, obtain resources
		controlsLabelNodes["Up"].text = "Up!"
		controlsLabelNodes["Down"].text = "Down!"
		controlsLabelNodes["Left"].text = "Left!"
		controlsLabelNodes["Right"].text = "Right!"
		if Input.is_action_just_released("ui_left"):
			inputsSystemNode.checkInput("left")
		elif Input.is_action_just_released("ui_right"):
			inputsSystemNode.checkInput("right")
		elif Input.is_action_just_released("ui_up"):
			inputsSystemNode.checkInput("up")
		elif Input.is_action_just_released("ui_down"):
			inputsSystemNode.checkInput("down")
	elif Input.is_action_pressed(keybinds["use"]):
		isCharging["useReleased"] = false
		controlsLabelNodes["Up"].text = "---"
		var action = hotbarNode.getAction()
		if !action:
			action = "---"
		controlsLabelNodes["Down"].text = action
		if action == "Hit" || action == "Water" || action == "Chop" || action == "Hammer" || action == "Sickle":
			isCharging["chargeAction"] = action
			controlsLabelNodes["Left"].text = "Charge\nLeft"
			controlsLabelNodes["Right"].text = "Charge\nRight"
			if Input.is_action_just_released("ui_left"):
				isCharging["chargeActionID"] = hotbarNode.getChargeLeftActionID()
			elif Input.is_action_just_released("ui_right"):
				isCharging["chargeActionID"] = hotbarNode.getChargeRightActionID()
		else:
			isCharging["chargeActionID"] = null
			controlsLabelNodes["Left"].text = "---"
			controlsLabelNodes["Right"].text = "---"
	elif !isCharging["useReleased"] && Input.is_action_just_released(keybinds["use"]):
		if isCharging["chargeActionID"]: #charging queued
			inputsSystemNode.startInputs(isCharging["function"], self, isCharging["chargeActionID"])
		else:
			reachNode.checkTileForDownAction(playerDirection, true)
		isCharging["useReleased"] = true
	else:
		controlsLabelNodes["Up"].text = reachNode.checkTileForUpAction(playerDirection)
		var downAction = hotbarNode.getAction()
		if !downAction:
			downAction = "---"
		controlsLabelNodes["Down"].text = downAction
		controlsLabelNodes["Left"].text = "---"
		controlsLabelNodes["Right"].text = "---"
		#when left or right is pressed while down is held, wait for down to be released then perform a charge
		#else if down is released, perform the action
		if Input.is_action_just_released(keybinds["harvest_pickup_enter"]):
			reachNode.checkTileForUpAction(playerDirection, inventoryNode, inputsSystemNode, true)
		elif Input.is_action_just_released(keybinds["talk"]):
			mouseClicked(4, get_global_mouse_position(), "tryToTalk")
		elif Input.is_action_just_released(keybinds["save"]):
			isRequestingSave = true
		elif Input.is_action_just_released(keybinds["load"]):
			isRequestingLoad = true
		elif Input.is_action_just_released(keybinds["hotkey1"]):
			hotbarNode.switchToSlot(0)
		elif Input.is_action_just_released(keybinds["hotkey2"]):
			hotbarNode.switchToSlot(1)
		elif Input.is_action_just_released(keybinds["hotkey3"]):
			hotbarNode.switchToSlot(2)
		elif Input.is_action_just_released(keybinds["hotkey4"]):
			hotbarNode.switchToSlot(3)
		elif Input.is_action_just_released(keybinds["hotkey5"]):
			hotbarNode.switchToSlot(4)
		elif Input.is_action_just_released(keybinds["testbutton2"]):
			pass

func angleToDirection(angle): #input is a player.angle_to_point(target) call
	if -3*PI/4 <= angle && angle < -PI/4: 
		return "Up"
	elif -PI/4 <= angle && angle < PI/4:
		return "Right"
	elif PI/4 <= angle && angle < 3*PI/4:
		return "Down"
	else:
		return "Left"

func turnPlayer(dir): #input is "Left" "Right" "Up" "Down"
	playerDirection = dir
	
	#play new walk or idle animation if different walk or idle animation is already playing
	if (animPlayer.current_animation).left(4) == "walk" || (animPlayer.current_animation).left(4) == "idle":
		var newAnim
		if isMoving:
			newAnim = "walk"
		else:
			newAnim = "idle"
		newAnim += playerDirection
		animPlayer.play(newAnim)
		handAnimPlayer.play(newAnim)

#returns true if objects were detected at the given mouse position on the given mask layer
func mouseClicked(mask, pos, method = ""):
	mouseParams.set_collision_mask(mask)
	mouseParams.set_position(pos)
	var query = mouseSpace.intersect_point(mouseParams)
	if query:
		for obj in query: #clickable objects: inventory tab, inventory slots
			print("Hit at point: ", obj["collider"].name)
			if obj["collider"].has_method(method):
				if method == "click": #ui
					var hasItemInMouse
					if itemInMouse:
						hasItemInMouse = true
					var slotItem = obj["collider"].click(hasItemInMouse) #if a slot was clicked, return values: "empty slot", itemNode in the slot
					if slotItem:
						#if there is no item in the mouse and no item was clicked, do nothing
						#if there is no item in the mouse and an item was clicked, pick up the item
						if !itemInMouse:
							if str(slotItem) != "empty slot":
								itemInMouse = slotItem
						#else if there is an item in the mouse,
						else:
							#if this is the item's original spot, put it down
							if itemInMouse.get_parent() == obj["collider"]:
								itemInMouse = null
							#else, try to put it in
							else: 
								itemInMouse = obj["collider"].putItem(itemInMouse)
						updateItemInMouse = true
					break
				elif method == "tryToTalk": #npc talk
					obj["collider"].tryToTalk()
					break
		return true

func useItemInHotbar(area):
	#do animation regardless if something happened
	var action = hotbarNode.getAction()
	var plantID
	if typeof(action) == TYPE_STRING:
		match action:
			"Wear":
				print("wear item")
				return
			"Consume":
				print("use item")
				return
			"Plant":
				plantID = hotbarNode.getItemID()
		if area.interact(action, plantID):
			hotbarNode.useItem(1)
	else:
		print("put item down")

func useChargedAction(chargeActionID = isCharging["chargeActionID"]):
	isCharging["chargeActionID"] = null
	match isCharging["chargeAction"]:
		"Hit":
			print("unleash charged " + isCharging["chargeAction"])
			animPlayer.play(str("slash", playerDirection))
			handAnimPlayer.play(str("slash", playerDirection))
			animPlayer.queue(str("idle", playerDirection))
			handAnimPlayer.queue(str("idle", playerDirection))
		"Water":
			print("unleash charged " + isCharging["chargeAction"])
		"Chop":
			print("unleash charged " + isCharging["chargeAction"])
		"Hammer":
			print("unleash charged " + isCharging["chargeAction"])
		"Sickle":
			print("unleash charged " + isCharging["chargeAction"])

#game controller signals
func handledTouchingQuestRequirements():
	isTouchingQuestRequirements = false

func getData():
	var playerData = {"player_id": playerID, "player_name": playerName, 
		"direction": playerDirection, "position_x": position.x, "position_y": position.y,
		"current_special_dialogue_checkpoint": currentSpecialDialogueCheckpoint}
	var inventoryData = getInventoryData()
	playerData.merge(inventoryData)
	var hotbarData = getHotbarData()
	playerData.merge(hotbarData)
	return playerData
func setData(saveFile):
	playerID = saveFile["player_id"]
	playerName = saveFile["player_name"]
	turnPlayer(saveFile["direction"])
	currentSpecialDialogueCheckpoint = saveFile["current_special_dialogue_checkpoint"]
	setInventoryData(saveFile)
	setHotbarData(saveFile)
func setPosition(pos):
	positions["targetPos"] = pos
	positions["last"] = pos
	positions["current"] = pos
	global_position = pos
func setCurrentSpecialDialogueCheckpoint(newCheckpoint):
	currentSpecialDialogueCheckpoint = newCheckpoint

func getInventoryData():
	return inventoryNode.getInventoryData()
func setInventoryData(saveFile):
	inventoryNode.setInventoryData(saveFile)
	
func getHotbarData():
	return hotbarNode.getHotbarData()
func setHotbarData(saveFile):
	hotbarNode.setHotbarData(saveFile)

func getEquips():
	pass
func setEquips():
	pass

func _on_npc_radius_area_entered(area):
	nearbyNPCs += [{"node": area, "unique_id": area.get_instance_id()}]

func _on_npc_radius_area_exited(area):
	var entryToRemove = nearbyNPCs.filter(func(r):return r["unique_id"]==area.get_instance_id())
	#print("trying to erase: ", entryToRemove[0], " from nearbyNPCs")
	nearbyNPCs.erase(entryToRemove[0])
	#print("after trying: ", nearbyNPCs)

