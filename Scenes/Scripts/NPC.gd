extends Area2D

var data = {}

var wantsSomething = false #signal to scene

func getID():
	return int(name.lstrip("NPC_"))
func getData():
	return data
func setData(saveData):
	data = saveData
func setSpritesheet(filename):
	var spritesheet = load(str("res://Assets/Ingame/Characters/", filename, ".tres"))
	$AnimatedSprite2D.set_sprite_frames(spritesheet)

func getNextDialogueID(currentSpecialDialogueCheckpoint): 
	if !data["is_current_special_dialogue_seen"]:
		data["is_current_special_dialogue_seen"] = 1
		return data[str("special_dialogue_id", currentSpecialDialogueCheckpoint)]
	else:
		return data["next_dialogue_id"]
func setNextDialogueID(id): 
	data["next_dialogue_id"] = id

func tryToTalk():
	wantsSomething = true
