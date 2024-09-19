extends Node2D
@onready var db = preload("res://Scenes/database_resource.gd").new()

var deletePlayerID #signal for game controller
var newPlayerID #signal for game controller
var playerID #signal for game controller

@onready var MenuOptionsNode = $Left/MenuOptions

@onready var TitleScreenNode = $Right/TitleScreen
@onready var PlayerSelectNode = $Right/PlayerSelect
@onready var ConfirmationScreenNode = $Right/ConfirmationScreen
@onready var OptionsNode = $Right/Options
@onready var BackNode = $Right/Back

#var currentLeft
var currentRight
var filesUsed

# Called when the node enters the scene tree for the first time.
func _ready():
	MenuOptionsNode.sceneNode = self
	PlayerSelectNode.sceneNode = self
	ConfirmationScreenNode.sceneNode = self
	
	#currentLeft = MenuOptionsNode
	currentRight = TitleScreenNode
	
	setPlayerSelect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func changeRight(task, pendingPlayerID = null):
	currentRight.set_visible(false)
	match task:
		"TitleScreen":
			currentRight = TitleScreenNode
			BackNode.set_visible(false)
		"PlayerSelect":
			currentRight = PlayerSelectNode
			BackNode.set_visible(true)
		"NewPlayer":
			currentRight = ConfirmationScreenNode
			currentRight.get_child(0).text = "Start a new life?"
			currentRight.pendingPlayerID = pendingPlayerID
			currentRight.task = task
			BackNode.set_visible(false)
		"DeletePlayer":
			currentRight = ConfirmationScreenNode
			currentRight.get_child(0).text = "Are you sure\nyou want to delete?"
			currentRight.pendingPlayerID = pendingPlayerID
			currentRight.task = task
			BackNode.set_visible(false)
		"Options":
			currentRight = OptionsNode
			BackNode.set_visible(true)
	currentRight.set_visible(true)

func setPlayerSelect():
	filesUsed = [false, false, false]
	var saveFiles = db.getQuery("save_data", "player_save", "player_id, player_name")
	for file in saveFiles:
		var player_id = file["player_id"]
		filesUsed[player_id] = true
		PlayerSelectNode.get_child(player_id).get_child(0).text = file["player_name"]
		PlayerSelectNode.get_child(player_id).get_child(1).set_visible(true)
	for file in filesUsed.size():
		if !filesUsed[file]:
			PlayerSelectNode.get_child(file).get_child(0).text = "New Player"
			PlayerSelectNode.get_child(file).get_child(1).set_visible(false)

func selectPlayer(playerIDSelected):
	if filesUsed[playerIDSelected]:
		playerID = playerIDSelected
	else:
		changeRight("NewPlayer", playerIDSelected)

func accept(task, pendingPlayerID):
	match task:
		"NewPlayer":
			newPlayerID = pendingPlayerID
		"DeletePlayer":
			deletePlayerID = pendingPlayerID
func decline(task):
	match task:
		"NewPlayer":
			changeRight("PlayerSelect")
		"DeletePlayer":
			changeRight("PlayerSelect")

func _on_back_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("LMB"):
		changeRight("TitleScreen")
