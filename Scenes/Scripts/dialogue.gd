extends Node
@onready var db = preload("res://Scenes/database_resource.gd").new()

var isDialogueOpen = false
var closeDialogueNextTime = false
var wantsToCloseDialogue = false #signal to scene to player
var newNextDialogueID = null #signal to the game controller to npc

var speakerNodes
var speakerNames = ["left_name1", "left_name2", "right_name1", "right_name2"]
var speakerFilenames = ["left_filename1", "left_filename2", "right_filename1", "right_filename2"]
var textboxNodes

# Called when the node enters the scene tree for the first time.
func _ready():
	speakerNodes = [$Speakers, $Speakers/Left1, $Speakers/Left2, $Speakers/Right1, $Speakers/Right2]
	textboxNodes = [$Textbox, $Textbox/Text, $Textbox/Basic]

func speak(dialogue_id):
	#close the dialogue
	if closeDialogueNextTime:
		closeDialogueNextTime = false
		hideAll()
		newNextDialogueID = dialogue_id #save this dialogue id as the next dialogue id in the npc
		wantsToCloseDialogue = true
		isDialogueOpen = false
		return null
	
	print(dialogue_id)
	
	#set up the dialogue
	var dialogue = db.getDictionary("parameters", "dialogue_data", "*", "dialogue_id", dialogue_id)
	setTextboxStyle(dialogue["textbox_style"])
	setSpeakerNames(dialogue)
	setSpeakerImages(dialogue)
	setDialogue(dialogue)
	#show the dialogue
	if !isDialogueOpen:
		isDialogueOpen = true
		showAll()
	
	#check if the dialogue should be closed on the next pass
	if dialogue["end_dialogue"]: 
		closeDialogueNextTime = true
	
	return dialogue["next_dialogue_id"]

func setTextboxStyle(style):
	pass
func setSpeakerNames(dialogue):
	pass #todo
func setSpeakerImages(dialogue):
	var speakerImageFilePath
	for i in 4:
		var speakerName = dialogue[speakerNames[i]]
		if speakerName != null:
			var expression = dialogue[speakerFilenames[i]]
			speakerImageFilePath = str("res://Assets/Portraits/", speakerName, "_", expression, ".png") #example: "res://Assets/Pepper_neutral.png"
		else:
			speakerImageFilePath = null
		setSpeakerImage(i+1, speakerImageFilePath)
func setSpeakerImage(position, file):
	var texture = null
	if file != null:
		texture = load(file)
	speakerNodes[position].set_texture(texture)
func setDialogue(dialogue):
	var text = dialogue["text1"]
	
	if dialogue["text2"] != null:
		text = text + " " + dialogue["text2"]
		if dialogue["text3"] != null:
			text = text + " " + dialogue["text3"]
		
	textboxNodes[1].text = text

func showAll():
	showSpeakers()
	showTextbox()
func hideAll():
	hideSpeakers()
	hideTextbox()

func showSpeakers():
	speakerNodes[0].visible = true
func hideSpeakers():
	speakerNodes[0].visible = false

func showTextbox():
	textboxNodes[0].visible = true
func hideTextbox():
	textboxNodes[0].visible = false
