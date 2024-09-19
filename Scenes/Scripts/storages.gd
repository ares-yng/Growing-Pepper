extends Node2D
@onready var db = preload("res://Scenes/database_resource.gd").new()

var storages

func _ready():
	storages = get_children()

func setStorageData(allData):
	for storage in storages:
		var storageData = db.findEntry(allData, "storage_id", storage.getID())
		#storage.setSpritesheet(storageData["ingame_filename"])
		storage.setData(storageData)
