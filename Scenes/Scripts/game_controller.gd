extends Node2D
@onready var db = preload("res://Scenes/database_resource.gd").new()

var loadTimer = null 

var isMainMenu = true

var PlayerNode
var currentSceneNode

var allSceneData
var allNPCData
var allStorageData

@onready var dialogueNode = $Pausable/CanvasLayer/Dialogue
@onready var pauseNode = $CanvasLayer/Pauser
@onready var clockNode = $Pausable/CanvasLayer/Clock

var nextDialogueID
var speakingNPC

# Called when the node enters the scene tree for the first time.
func _ready():
	currentSceneNode = $Pausable/main_menu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isMainMenu:
		if currentSceneNode.deletePlayerID != null:
			deletePlayer(currentSceneNode.deletePlayerID)
			currentSceneNode.deletePlayerID = null
		elif currentSceneNode.newPlayerID != null:
			setupNewPlayer(currentSceneNode.newPlayerID)
			currentSceneNode.newPlayerID = null
		elif currentSceneNode.playerID != null:
			var player = load("res://Scenes/Prefabs/Player.tscn")
			PlayerNode = player.instantiate()
			PlayerNode.playerID = currentSceneNode.playerID
			$Pausable.add_child(PlayerNode)
			loadFile(currentSceneNode.playerID, false)
			pauseNode.isPlaying = true
			isMainMenu = false
			clockNode.set_visible(true)
	else:
		if Input.is_action_just_pressed("testbutton3"):
			advance()
		
		#Monitors player signals
		#if PlayerNode.isRequestingSave:
		#	saveFile()
		#	PlayerNode.isRequestingSave = false
		#if PlayerNode.isRequestingLoad:
		#	loadFile()
		#	PlayerNode.isRequestingLoad = false
		if PlayerNode.isTouchingQuestRequirements:
			currentSceneNode.checkNPCQuestRequirements()
			PlayerNode.handledTouchingQuestRequirements()
		if PlayerNode.isRequestingDialogue:
			nextDialogueID = dialogueNode.speak(nextDialogueID)
			PlayerNode.isRequestingDialogue = false
		#todo: when player passes checkpoint, update PlayerNode.currentSpecialDialogueCheckpoint
		
		#Monitors scene signals
		if currentSceneNode.NPCWantsToSpeak:
			if !dialogueNode.isDialogueOpen:
				speakingNPC = currentSceneNode.NPCWantsToSpeak
				nextDialogueID = dialogueNode.speak(currentSceneNode.getNextDialogueID(speakingNPC, PlayerNode.currentSpecialDialogueCheckpoint))
				PlayerNode.isDialogueOpen = true
			currentSceneNode.NPCWantsToSpeak = null
		if currentSceneNode.requestingSceneChange:
			if dialogueNode.isDialogueOpen:
				PlayerNode.isDialogueOpen = false
				dialogueNode.isDialogueOpen = false
				dialogueNode.hideAll()
			currentSceneNode = openScene(currentSceneNode.requestingSceneChange[0], currentSceneNode.requestingSceneChange[1])
		
		#Monitors dialogue signals
		if dialogueNode.wantsToCloseDialogue:
			if dialogueNode.newNextDialogueID:
				speakingNPC.setNextDialogueID(dialogueNode.newNextDialogueID)
			PlayerNode.isDialogueOpen = false
			dialogueNode.wantsToCloseDialogue = false
		
		#Monitors journal signals
		if pauseNode.saveRequest != null:
			saveFile(pauseNode.saveRequest)
			pauseNode.refresh()
			pauseNode.saveRequest = null
		if loadTimer:
			if loadTimer < 0:
				pauseNode.pause()
				loadTimer = null
			else:
				loadTimer -= delta*1000
		if pauseNode.loadRequest != null:
			loadFile(pauseNode.loadRequest)
			pauseNode.unpause()
			loadTimer = 50 #small buffer time for player to load in fully. may need adjustments
			pauseNode.loadRequest = null

func advance(): #advances to the next day
	var delimiter = ";"
	var plantData = db.getQuery("parameters", "plant_data")
	
	tempSave(currentSceneNode)
	
	for scene in allSceneData.size(): #iterate through all scenes
		print(allSceneData[scene])
		var plant_ids = allSceneData[scene]["plant_id"].split(delimiter)
		var tile_growth_stages = allSceneData[scene]["tile_growth_stage"].split(delimiter)
		var tile_is_watereds = allSceneData[scene]["tile_is_watered"].split(delimiter)
		var numPlants = plant_ids.size()
		
		#update plants
		for i in numPlants:
			var plant_id = int(plant_ids[i])
			#if there is a plant,
			if plant_id != 0:
				#if it isn't fully grown,
				var plantGrowthTime = db.findEntry(plantData, "item_id", plant_id)["growth_time"]
				var tile_growth_stage = int(tile_growth_stages[i])
				if tile_growth_stage < plantGrowthTime:
					#if it is watered
					if tile_is_watereds[i] == "1":
						#grow it
						tile_growth_stage += 1
						tile_growth_stages[i] = str(tile_growth_stage)
		
		#all watered tiles become dry
		for i in numPlants:
			tile_is_watereds[i] = "0"
		
		#store updated data
		var new_tile_growth_stages = ""
		var new_tile_is_watereds = ""
		for i in numPlants:
			new_tile_growth_stages += str(tile_growth_stages[i], delimiter)
			new_tile_is_watereds += str(tile_is_watereds[i], delimiter)
		new_tile_growth_stages = new_tile_growth_stages.left(-1)
		new_tile_is_watereds = new_tile_is_watereds.left(-1)
		allSceneData[scene]["tile_growth_stage"] = new_tile_growth_stages
		allSceneData[scene]["tile_is_watered"] = new_tile_is_watereds
		print(allSceneData[scene])
	
	#reload scene
	currentSceneNode = openScene(currentSceneNode.scene_id, PlayerNode.global_position, false)
	#todo: set date

#Game Managing
func setupNewPlayer(new_player_id):
	#initialize player
	var playerData = {"player_id": new_player_id} #, "player_name": "Pepper"
	db.saveRow("save_data", "player_save", playerData)
	currentSceneNode.setPlayerSelect()
	currentSceneNode.changeRight("PlayerSelect")
	
	#initialize scenes
	allSceneData = db.getQuery("parameters", "scene_data")
	for i in allSceneData.size():
		if i == 0: #skip main_menu
			continue
		var scene = load(str("res://Scenes/Maps/", allSceneData[i]["scene_filename"],".tscn")).instantiate()
		$Pausable.add_child(scene) #triggers all scene nodes' _ready()
		var sceneData = scene.getSceneData()
		allSceneData[i]["player_id"] = new_player_id
		allSceneData[i].merge(sceneData)
		scene.free()
		print(allSceneData[i])
		db.saveRow("save_data","scene_save", allSceneData[i])
	
	#initialize npcs
	allNPCData = db.getQuery("parameters", "npc_data")
	for i in allNPCData.size():
		allNPCData[i]["player_id"] = new_player_id
		#copy npc data into the save file with the new player id
		var npcSaveData = {"player_id": allNPCData[i]["player_id"], "npc_id": allNPCData[i]["npc_id"],
			"next_dialogue_id": allNPCData[i]["initial_dialogue_id"],
			"is_current_special_dialogue_seen": 0}
		print(npcSaveData)
		db.saveRow("save_data","npc_dialogue_save", npcSaveData)

func deletePlayer(player_id):
	db.deleteRow("save_data", "player_save", "player_id", player_id)
	db.deleteRow("save_data", "scene_save", "player_id", player_id)
	db.deleteRow("save_data", "npc_dialogue_save", "player_id", player_id)
	currentSceneNode.setPlayerSelect()
	currentSceneNode.changeRight("PlayerSelect")

func saveFile(playerID): #saves to specified file
	#check if a save file has been initialized
	var saveFiles = db.getQuery("save_data", "player_save", "player_id")
	var saveFileExists = false
	for file in saveFiles:
		if file["player_id"] == playerID:
			saveFileExists = true
	
	#player
	var time = clockNode.getTime()
	var playerData = PlayerNode.getData()
	playerData["scene_id"] = currentSceneNode.scene_id
	playerData["time"] = time
	playerData["player_id"] = playerID
	if saveFileExists:
		db.saveRow("save_data", "player_save", playerData, "player_id", playerData["player_id"])
	else:
		db.saveRow("save_data", "player_save", playerData)
	
	#update changes in current scene
	tempSave(currentSceneNode)
	#save all scenes
	for data in allSceneData:
		data["player_id"] = playerID
		if saveFileExists:
			db.saveRow("save_data", "scene_save", data, "player_id", data["player_id"], "scene_id", data["scene_id"])
		else:
			db.saveRow("save_data", "scene_save", data)
	
	#save all npcs
	for data in allNPCData:
		data["player_id"] = playerID
		var npcSaveData = {"player_id": data["player_id"], "npc_id": data["npc_id"],
			"next_dialogue_id": data["next_dialogue_id"],
			"is_current_special_dialogue_seen": data["is_current_special_dialogue_seen"]}
		if saveFileExists:
			db.saveRow("save_data", "npc_dialogue_save", npcSaveData, "player_id", npcSaveData["player_id"], "npc_id", npcSaveData["npc_id"])
		else:
			db.saveRow("save_data", "npc_dialogue_save", npcSaveData)
	
	#save all storages
	for data in allStorageData:
		data["player_id"] = playerID
		if saveFileExists:
			db.saveRow("save_data", "storage_save", data, "player_id", data["player_id"], "storage_id", data["storage_id"])
		else:
			db.saveRow("save_data", "storage_save", data)

func loadFile(player_id = PlayerNode.playerID, doRefreshPlayer = true): #loads last saved information of given player id file
	#player
	if doRefreshPlayer:
		PlayerNode.name = "Trash"
		PlayerNode.queue_free() 
		
		var newPlayer = load(str("res://Scenes/Prefabs/Player.tscn")).instantiate()
		$Pausable.add_child(newPlayer)
		newPlayer.name = "Player"
		newPlayer.playerID = player_id
		PlayerNode = newPlayer
	
	var playerData = db.getDictionary("save_data", "player_save", "*", "player_id", player_id) 
	PlayerNode.setData(playerData)
	
	#storages
	allStorageData = db.findEntries(db.getQuery("save_data", "storage_save"), "player_id", player_id)
	
	#npcs
	allNPCData = db.getQuery("parameters", "npc_data")
	var tempNPCData = db.findEntries(db.getQuery("save_data", "npc_dialogue_save"), "player_id", player_id)
	for i in allNPCData.size(): #combine necessary data
		allNPCData[i]["player_id"] = player_id
		if allNPCData[i]["npc_id"] == tempNPCData[i]["npc_id"]:
			allNPCData[i]["next_dialogue_id"] = tempNPCData[i]["next_dialogue_id"]
			allNPCData[i]["is_current_special_dialogue_seen"] = tempNPCData[i]["is_current_special_dialogue_seen"]
		print(str(i, ": ", allNPCData[i]))
	
	#scenes
	allSceneData = db.findEntries(db.getQuery("save_data", "scene_save"), "player_id", player_id)
	var savedPosition = Vector2(playerData["position_x"], playerData["position_y"])
	
	currentSceneNode = openScene(playerData["scene_id"], savedPosition, false)
	
	#do last for most accuracy
	clockNode.setTime(playerData["time"])

#Scene Managing
func openScene(scene_id, playerPos = 0, saveCurrent = true): #opens scene from load or changing maps
	#update changed scene data
	if saveCurrent:
		tempSave(currentSceneNode)
	
	#set up new scene
	var newSceneData = db.findEntry(allSceneData, "scene_id", scene_id)
	var newSceneNode = load(str("res://Scenes/Maps/", newSceneData["scene_filename"],".tscn")).instantiate()
	$Pausable.add_child(newSceneNode)
	currentSceneNode.name = "Trash"
	currentSceneNode.queue_free() #delete old scene from tree
	newSceneNode.name = "Scene"
	
	var newStorageData = []
	for id in newSceneNode.getStorageIDs():
		var data = db.findEntry(allStorageData, "storage_id", id)
		if data == null:
			data = initializeStorage(id)
			allStorageData += [data]
		newStorageData += [data]
	
	newSceneNode.setData(newSceneData, allNPCData, newStorageData)
	
	#set player position
	if typeof(playerPos) == TYPE_INT: 
		playerPos = newSceneNode.getPlayerSpawnLocation(playerPos)
	elif playerPos.is_zero_approx():
		playerPos = newSceneNode.getPlayerSpawnLocation()
	PlayerNode.setPosition(playerPos)
	$Pausable.move_child(PlayerNode, -1) #change PlayerNode position to the last in the node tree
	
	return newSceneNode

func tempSave(scene): #saves the given scene's data to this script (not to the database)
	#get scene data
	if !scene.has_method("getData"):
		return
	var sceneData = scene.getData()
	
	#replace scene data
	var parameters = ["plant_id", "tile_growth_stage", "tile_is_watered", #farmlandParameters
		"item_id", "quantity", "location"] #floorGridParameters
	var dataIndex = allSceneData.find(db.findEntry(allSceneData, "scene_id", scene.scene_id)) #finds the index by searching by the scene id then finding a match
	for parameter in parameters:
		allSceneData[dataIndex][parameter] = sceneData[parameter]
	
	#replace npc data
	var type = "npc"
	parameters = ["next_dialogue_id", "is_current_special_dialogue_seen"] #npcParameters
	for num in sceneData[str(type, "_num")]:
		var typeID = sceneData[str(type, num)][str(type, "_id")]
		dataIndex = allNPCData.find(db.findEntry(allNPCData, str(type, "_id"), typeID))
		for parameter in parameters:
			allNPCData[dataIndex][parameter] = sceneData[str(type, num)][parameter]
	
	#replace storage data
	type = "storage"
	parameters = ["item_id", "quantity"] #storageParameters
	for num in sceneData[str(type, "_num")]:
		var typeID = sceneData[str(type, num)][str(type, "_id")]
		dataIndex = allStorageData.find(db.findEntry(allStorageData, str(type, "_id"), typeID))
		for parameter in parameters:
			allStorageData[dataIndex][parameter] = sceneData[str(type, num)][parameter]

func initializeStorage(id): #returns a storage dictionary
	var storageParameters = db.getDictionary("parameters", "storage_data", "*", "storage_id", id)
	var storage = {"player_id": PlayerNode.playerID, "storage_id": id}
	var string = ""
	
	for num in storageParameters["storage_slots"]-1:
		string += ";"
	storage["item_id"] = string
	storage["quantity"] = string
	
	db.saveRow("save_data","storage_save", storage)
	return storage
