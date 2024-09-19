extends Node2D
@onready var db = preload("res://Scenes/database_resource.gd").new()
#@onready var dialogue = preload("res://Scenes/dialogue_resource.gd").new()

var scene_id

@onready var FarmlandTileNode = $FarmlandTile
@onready var FloorGridNode = $FloorGrid
@onready var NPCsNode = $NPCs
@onready var PortalsNode = $Portals
@onready var StoragesNode = $Storages

var NPCWantsToSpeak = null #signal to game controller 
var requestingSceneChange = null #signal to game controller 

#remember to update parameters in game controller too
var farmlandParameters = ["plant_id", "tile_growth_stage", "tile_is_watered"]
var npcParameters = ["npc_id", "next_dialogue_id", "is_current_special_dialogue_seen"]
var floorGridParameters = ["item_id", "quantity", "location"]
var portalParameters = ["portal_scene_ids"]
var storageParameters = ["storage_id", "item_id", "quantity"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#monitor npc signals
	for npc in NPCsNode.NPCs:
		if npc.wantsSomething:
			npc.wantsSomething = false
			NPCWantsToSpeak = npc
			break

func getNextDialogueID(npc, currentSpecialDialogueCheckpoint):
	return npc.getNextDialogueID(currentSpecialDialogueCheckpoint)
func setNextDialogueID(npc, id):
	npc.setNextDialogueID(id)

func getStorageIDs(): #returns an array of storage ids
	var ids = []
	for storage in StoragesNode.storages:
		ids += [storage.getID()]
	return ids
func getPlayerSpawnLocation(index = 0):
	return PortalsNode.get_child(index).get_global_position()
func getSceneData():
	var sceneData = getPackedChildrenData(FarmlandTileNode, farmlandParameters)
	sceneData.merge(FloorGridNode.getData(floorGridParameters))
	return sceneData
func getData():
	var saveData = getSceneData()
	
	var numNPCs = 0
	for npc in NPCsNode.NPCs: #add all the npc data
		saveData.merge({str("npc", numNPCs): npc.getData()})
		numNPCs += 1
	saveData.merge({"npc_num": numNPCs})
	
	var numStorages = 0
	for storage in StoragesNode.storages: #all all the storage data
		saveData.merge({str("storage", numStorages): storage.getData()})
		numStorages += 1
	saveData.merge({"storage_num": numStorages})
	
	return saveData
func setData(saveData, npcData, storageData): #note: add scene to tree before calling this function
	scene_id = saveData["scene_id"]
	setPackedChildrenData(saveData, FarmlandTileNode, farmlandParameters)
	FloorGridNode.setData(saveData, floorGridParameters)
	NPCsNode.setNPCData(npcData)
	StoragesNode.setStorageData(storageData)

func getPackedChildrenData(object, parameters):
	var delimiter = ";"
	var data = {}
	for i in parameters.size(): #initialize dictionary
		data[parameters[i]] = ""
	
	var numChildren = object.get_child_count()
	for i in numChildren: #for each child,
		var childData = object.get_child(i).getData()
		for j in parameters.size(): #and for each parameter,
			data[parameters[j]] += str(childData[parameters[j]], delimiter) #concat its data to all the data
	for i in parameters.size(): #remove extra delimiter from each parameter
		data[parameters[i]] = data[parameters[i]].left(-1)
	
	return data
func setPackedChildrenData(data, object, parameters):
	var numChildren = object.get_child_count()
	if numChildren > 0:
		var delimiter = ";"
		var dataCopy = {}
		for i in parameters.size():
			dataCopy[parameters[i]] = data[parameters[i]].split(delimiter) #data converted into arrays, where each index represents a child
		
		for i in numChildren: #for each child,
			var childData = {}
			for j in parameters.size(): #load each parameter
				childData[parameters[j]] = int(dataCopy[parameters[j]][i])
			object.get_child(i).setData(childData) #set data
