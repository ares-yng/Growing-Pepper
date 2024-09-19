extends Node2D

@onready var arms = {"Left": $Left, "Right": $Right, "Up": $Up, "Down": $Down}
var tileSize = 32
var defaultPositions = {}

func _ready():
	defaultPositions["Left"] = arms["Left"].get_position()
	defaultPositions["Right"] = arms["Right"].get_position()
	defaultPositions["Up"] = arms["Up"].get_position()
	defaultPositions["Down"] = arms["Down"].get_position()

#input: direction the player is facing, whether the area should be acted on
#output: the up action the player would take
func checkTileForUpAction(playerDirection, inventoryNode = null, inputsSystemNode = null, doAction = false):
	setArmPosition(playerDirection)
	var interactableAreas = arms[playerDirection].get_child(0).get_overlapping_areas()
	if interactableAreas:
		for area in interactableAreas:
			if area.has_method("enter"):
				if doAction:
					area.enter()
					return
				else:
					return "Enter"
			elif area.has_method("pickup"):
				if doAction:
					inventoryNode.putItem(area)
					return
				else:
					return "Pick Up"
			elif area.has_method("harvest"):
				if area.harvestRequest() != 0:
					if doAction:
						inputsSystemNode.startInputs("harvest", area)
						return
					else:
						return "Harvest"
	return "---"

func checkTileForDownAction(playerDirection, doAction = false):
	setArmPosition(playerDirection)
	var interactableAreas = arms[playerDirection].get_child(0).get_overlapping_areas()
	if interactableAreas:
		for area in interactableAreas:
			if area.has_method("interact"):
				if doAction:
					get_parent().useItemInHotbar(area)
					return
	return "---"

#return array of tile corners (in inverse C order) given a position in global space
func getTileCorners(pos):
	var tileCorner = Vector2i(pos/tileSize) * tileSize
	tileCorner.x += tileSize
	tileCorner.y += tileSize
	var tileCorners = [tileCorner]
	tileCorner.x -= tileSize
	tileCorners += [tileCorner]
	tileCorner.y -= tileSize
	tileCorners += [tileCorner]
	tileCorner.x += tileSize
	tileCorners += [tileCorner]
	return tileCorners

func setArmPosition(direction):
	arms[direction].set_position(defaultPositions[direction])
	#position over the grid
	var pos = arms[direction].get_global_position()
	var tilePos = Vector2i(pos/tileSize) * tileSize
	tilePos.x += tileSize/2
	tilePos.y += tileSize/2
	arms[direction].set_global_position(tilePos)
