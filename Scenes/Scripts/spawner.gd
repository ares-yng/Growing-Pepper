extends Node2D

@onready var db = preload("res://Scenes/database_resource.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	for spawnPoint in get_children():
		var id = spawnPoint.name.lstrip("Spawnpoint_")
		id = int(id.rstrip(";")) #godot node names must be unique
		spawnEnemy(spawnPoint.global_position, id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawnEnemy(location, id):
	var data = db.getDictionary("parameters", "enemy_data", "*", "enemy_id", id)
	
	var enemyPrefab = load("res://Scenes/Prefabs/Enemy.tscn")
	var newEnemy = enemyPrefab.instantiate()
	add_child(newEnemy)
	newEnemy.setData(data)
	newEnemy.set_global_position(location)
	
	print("instantiated children: ")
	for i in self.get_children():
		print(i)
