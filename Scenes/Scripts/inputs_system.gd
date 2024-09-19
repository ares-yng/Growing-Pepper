extends Node2D
@onready var db = load("res://Scenes/database_resource.gd").new()

var playerNode

@onready var inputsDisplayNode = $InputsDisplay
var inputsTarget
var inputsType
var inputs
var currentInput

func checkInput(direction):
	if direction == inputs[currentInput]:
		print("successful input")
		inputsDisplayNode.updateDisplayedInput(currentInput, true)
		currentInput += 1
		if currentInput > inputs.size()-1:
			successfulInputs()
	else:
		#playerNode.playanimation(idle)
		endInputs()
		
func successfulInputs():
	match inputsType:
		"harvest":
			inputsTarget.harvest()
			#playerNode.playanimation(harvest)
		"charge":
			inputsTarget.useChargedAction()
			#playerNode.playanimation(action)
	#playerNode.queueanimation(idle)
	endInputs()
func endInputs():
	print("inputs ended.")
	inputsTarget = null
	inputsDisplayNode.hideInputs()

func startInputs(function, object, id = null):
	inputsType = function
	match inputsType:
		"harvest":
			var harvestPatternId = object.harvestRequest()
			if harvestPatternId != 0:
				setupInputs(harvestPatternId, object)
				#playerNode.playanimation(harvesting)
		"charge":
			var patternID = db.getValue("parameters", "charge_action_data", "charge_action_id", id, "input_pattern_id")
			setupInputs(patternID, object)
			#playerNode.playanimation(charging)

func setupInputs(patternID, object):
	var inputsPattern = db.getDictionary("parameters", "input_patterns", "*", "input_pattern_id", patternID)
	inputs = inputsDisplayNode.newWeightedInputs(inputsPattern, db.getQuery("parameters", "weighted_inputs", "*"))
	currentInput = 0
	inputsTarget = object
