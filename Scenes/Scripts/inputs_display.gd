extends HBoxContainer

var inputNodes = []
var arrowNodes = []
var arrowChildIndex = 1

var arrowWidth = 16
var separation = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in self.get_children():
		inputNodes += [i]
		arrowNodes += [i.get_child(arrowChildIndex)]
	
	self.add_theme_constant_override("separation", arrowWidth+separation)
	self.alignment = BoxContainer.ALIGNMENT_CENTER

#starts a new input sequence
func newWeightedInputs(harvestPattern, weights):
	var inputsArray = []
	
	for i in 6:
		var weightedInputID = harvestPattern[str("weighted_input_id", i+1)]
		if weightedInputID == null:
			break
		var nextInput = newWeightedInput(weights.filter(func(r):return r["weighted_input_id"]==weightedInputID)[0])
		inputsArray += [nextInput]
	
	print(str("final inputs: ", inputsArray))
	
	showInputs(inputsArray)
	return inputsArray

#returns one new weighted direction given weights
func newWeightedInput(weights):
	print(weights)
	var directions = ["left", "right", "up", "down"]
	var totalWeights = 0
	
	var rng = RandomNumberGenerator.new()
	var rn = rng.randf_range(0,1)
	print("random number: ", rn)
	
	for i in 4:
		var weight = weights[str(directions[i], "_weight")]
		if weight != 0:
			if totalWeights <= rn && rn <= totalWeights + weight:
				print(str("chosen: ", directions[i]))
				return directions[i]
			else:
				totalWeights += weight

func updateDisplayedInput(inputIndex, sameInput, direction = 0):
	if sameInput:
		arrowNodes[inputIndex].set_frame(arrowNodes[inputIndex].get_frame() + 4)
	else:
		arrowNodes[inputIndex].set_frame(direction)

func showInputs(inputsArray):
	for i in inputNodes.size():
		if i < inputsArray.size():
			match inputsArray[i]:
				"left":
					updateDisplayedInput(i, false, 0)
				"right":
					updateDisplayedInput(i, false, 1)
				"up":
					updateDisplayedInput(i, false, 2)
				"down":
					updateDisplayedInput(i, false, 3)
			inputNodes[i].set_visible(true)
		else:
			inputNodes[i].set_visible(false)
	set_visible(true)
func hideInputs():
	set_visible(false)
