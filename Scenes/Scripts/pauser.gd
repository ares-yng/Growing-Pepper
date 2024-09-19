extends Node2D

var isPlaying = false #signal from game controller if game is pausable
var currentMenu = null
@onready var pages = [$SaveLoad, $Quests, $ToDo, $Map, $DevTools]
var saveRequest = null
var loadRequest = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#set up the pages
	var viewportSize = get_viewport().get_visible_rect().size
	print(viewportSize)
	var leftTitlePos = Vector2(-viewportSize.x/4 + viewportSize.x/30, -viewportSize.y/5*2 + viewportSize.y/30)
	var leftContentPos = Vector2(-viewportSize.x/4 + viewportSize.x/30, 0)
	var rightTitlePos = Vector2(viewportSize.x/4 - viewportSize.x/30, -viewportSize.y/5*2 + viewportSize.y/30)
	var rightContentPos = Vector2(viewportSize.x/4 - viewportSize.x/30, -viewportSize.y/11*2)
	
	var leftTitle
	var leftContent
	var rightContent
	
	leftTitle = pages[0].get_node("LeftTitle")
	leftTitle.position = leftTitlePos 
	
	leftContent = pages[0].get_node("LeftContent")
	leftContent.position = leftContentPos
	
	rightContent = pages[0].get_node("RightContent")
	rightContent.position = rightContentPos 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isPlaying && Input.is_action_just_pressed("pause"):
		checkPress("saveload", pages[0])
		checkPress("quests", pages[1])
		checkPress("todo", pages[2])
		checkPress("map", pages[3])
		checkPress("testbutton2", pages[4])
	
	if pages[0].saveRequest != null:
		saveRequest = pages[0].saveRequest
		pages[0].saveRequest = null
	if pages[0].loadRequest != null:
		loadRequest = pages[0].loadRequest
		pages[0].loadRequest = null

func checkPress(input, menuNode): 
	if Input.is_action_just_pressed(input):
		if currentMenu == null: #start pause
			get_tree().paused = true
			pages[0].setToDefault()
			currentMenu = menuNode
			$JournalBacking.set_visible(true)
			currentMenu.set_visible(true)
			currentMenu.process_mode = Node.PROCESS_MODE_INHERIT
		elif currentMenu == menuNode: #end pause if the same button is pressed
			currentMenu.set_visible(false)
			currentMenu.process_mode = Node.PROCESS_MODE_DISABLED
			currentMenu = null
			$JournalBacking.set_visible(false)
			get_tree().paused = false
		else: #open different menu
			currentMenu.set_visible(false)
			currentMenu.process_mode = Node.PROCESS_MODE_DISABLED
			currentMenu = menuNode
			currentMenu.set_visible(true)
			currentMenu.process_mode = Node.PROCESS_MODE_INHERIT

func pause():
	if currentMenu:
		get_tree().paused = true
func unpause():
	get_tree().paused = false

func refresh():
	pages[0].displaySave()

func addSave():
	pass
func removeSave():
	pass
func updateSave():
	pass

func addQuest():
	pass
func removeQuest():
	pass

func addTodo():
	pass
func removeTodo():
	pass
