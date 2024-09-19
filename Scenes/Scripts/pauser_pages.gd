extends Node2D
@onready var db = preload("res://Scenes/database_resource.gd").new()

#saveload vars
var initialized = false
var mouseHoveringOver = null
var mouseParams
var mouseSpace
var entry1
var entry2
var entry3
var saveNode
var loadNode
var displayedFile
var saveRequest = null #signal to pauser to gamecontroller
var loadRequest = null #signal to pauser to gamecontroller
var fileData

# Called when the node enters the scene tree for the first time.
func _ready():
	if name == "SaveLoad":
		entry1 = $LeftContent/Label
		entry2 = $LeftContent/Label2
		entry3 = $LeftContent/Label3
		saveNode = $RightContent/Save
		loadNode = $RightContent/Load
		mouseSpace = get_world_2d().get_direct_space_state()
		mouseParams = PhysicsPointQueryParameters2D.new()
		mouseParams.set_collide_with_areas(true)
		mouseParams.set_collision_mask(32)
	elif name == "Quests":
		pass
	elif name == "ToDo":
		pass
	elif name == "Map":
		pass
	else:
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if name == "SaveLoad":
		if !initialized:
			entry1.grab_focus()
			set_focusIndicatorPos(entry1)
			
			var canvaslayer = get_parent()
			while canvaslayer.name != "CanvasLayer":
				canvaslayer = canvaslayer.get_parent()
			mouseParams.set_canvas_instance_id(canvaslayer.get_instance_id())
			
			$RightContent/Label.text = ""
			saveNode.set_visible(false)
			saveNode.process_mode = Node.PROCESS_MODE_DISABLED
			loadNode.set_visible(false)
			loadNode.process_mode = Node.PROCESS_MODE_DISABLED
			
			displayedFile = null
			initialized = true
			
			#fileData = [null, null, null]
			#var saveFiles = db.getQuery("save_data", "player_save", "player_id, player_name, time, scene_id")
			#for file in saveFiles:
			#	var player_id = file["player_id"]
			#	fileData[player_id] = file
		
		mouseParams.set_position(get_global_mouse_position())
		var query = mouseSpace.intersect_point(mouseParams)
		if query:
			for obj in query: 
				if obj["collider"].get_parent().name == "Label":
					entry1.grab_focus()
					set_focusIndicatorPos(entry1)
					mouseHoveringOver = entry1
					break
				elif obj["collider"].get_parent().name == "Label2":
					entry2.grab_focus()
					set_focusIndicatorPos(entry2)
					mouseHoveringOver = entry2
					break
				elif obj["collider"].get_parent().name == "Label3":
					entry3.grab_focus()
					set_focusIndicatorPos(entry3)
					mouseHoveringOver = entry3
					break
				elif obj["collider"].get_parent().name == "Save":
					mouseHoveringOver = saveNode 
				elif obj["collider"].get_parent().name == "Load":
					mouseHoveringOver = loadNode
				else:
					mouseHoveringOver = null
		else:
			mouseHoveringOver = null
		
		if Input.is_action_just_pressed("LMB"):
			if mouseHoveringOver == entry1:
				displayedFile = 0
				displaySave()
			elif mouseHoveringOver == entry2:
				displayedFile = 1
				displaySave()
			elif mouseHoveringOver == entry3:
				displayedFile = 2
				displaySave()
			elif mouseHoveringOver == saveNode:
				saveRequest = displayedFile
			elif mouseHoveringOver == loadNode:
				loadRequest = displayedFile
	elif name == "Quests":
		pass
	elif name == "ToDo":
		pass
	elif name == "Map":
		pass
	else:
		pass

#global functions
func setToDefault():
	if name == "SaveLoad":
		initialized = false
	elif name == "Quests":
		pass
	elif name == "ToDo":
		pass
	elif name == "Map":
		pass
	else:
		pass

#saveload functions
func set_focusIndicatorPos(focusedNode):
	var focusIndicatorPos = focusedNode.position
	var offset = Vector2(-64, 0)
	focusIndicatorPos.x += offset.x
	focusIndicatorPos.y += offset.y
	offset = focusedNode.size
	focusIndicatorPos.x += offset.x/2
	focusIndicatorPos.y += offset.y/2
	$LeftContent/FocusIndicator.position = focusIndicatorPos
func displaySave(fileNum = displayedFile):
	fileData = [null, null, null]
	var saveFiles = db.getQuery("save_data", "player_save", "player_id, player_name, time, scene_id")
	for file in saveFiles:
		var player_id = file["player_id"]
		fileData[player_id] = file
		
	if fileData[fileNum]:
		var year = fileNum + 1
		var month = 2
		var day = 15
		
		var savedTime = fileData[fileNum]["time"]
		var displayTime = -10000
		while savedTime >= displayTime + 10000:
			displayTime += 10000
		
		var hour = str(displayTime/60000)
		if hour.length() == 1:
			hour = str("0", hour)
		
		var mins = str(displayTime%60000).left(1)
		mins = str(mins, "0")
		
		var time = str(hour, ":", mins)
		
		var date = str("Year ", year, " Month ", month, " Day ", day, ", ", time)
		var scene = fileData[fileNum]["scene_id"] 
		$RightContent/Label.text = str(date, "\n", scene)
	else:
		$RightContent/Label.text = "Empty Entry"
	saveNode.set_visible(true)
	saveNode.process_mode = Node.PROCESS_MODE_INHERIT
	loadNode.set_visible(true)
	loadNode.process_mode = Node.PROCESS_MODE_INHERIT
