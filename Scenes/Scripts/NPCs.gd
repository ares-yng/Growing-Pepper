extends Node2D
@onready var db = preload("res://Scenes/database_resource.gd").new()

var NPCs 

func _ready():
	NPCs = get_children()

func setNPCData(allData):
	for npc in NPCs:
		var NPCData = db.findEntry(allData, "npc_id", npc.getID())
		npc.setSpritesheet(NPCData["ingame_filename"])
		npc.setData(NPCData)
