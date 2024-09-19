extends CharacterBody2D

var data = {}
@onready var stats = $Stats
@onready var animationPlayer = $AnimatedSprite2D/AnimationPlayer
var dead = false
var behavior = ["neutral", "neutral", "neutral"] #detection, attacked, last
var counter = [500, 500, 500, 500, 0, 0] #attack1, attack2, attacks, actions, attacked, detection

#movement vars
var isPlayerInRange = false
var playerNode
var moveGoal
var moveRequest = false
var speed
var lastPosition = null
var distanceToCover
var distanceMoved = 1

func _physics_process(delta):
	if distanceToCover && distanceToCover >= 1 && distanceMoved >= .3: #start or keep moving
		if lastPosition == null:
			lastPosition = position
		else:
			distanceMoved = position.distance_to(lastPosition)
			lastPosition = position
		velocity = position.direction_to(moveGoal) * speed
		move_and_slide()
		distanceToCover -= lastPosition.distance_to(position)
	elif (distanceToCover && distanceToCover < 1) || distanceMoved < .3: #stop moving
		lastPosition = null
		distanceToCover = null
		counter[3] = getCooldown(3)
		animationPlayer.play("idle")
		distanceMoved = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stats.health <= 0:
		if dead:
			if animationPlayer.current_animation == "":
				queue_free()
		else:
			die()
	else:
		#cooldowns
		for i in counter.size():
			if counter[i] >= 0:
				counter[i] -= delta*1000
		
		if stats.wasHurt: #reset attacked counter due to being attacked
			animationPlayer.play("hit")
			animationPlayer.queue("idle")
			behavior[1] = getBehavior("attacked")
			counter[4] = getCooldown(4)
			playerNode = stats.wasHurtBy
			stats.wasHurtBy = null
			stats.wasHurt = false
		elif behavior[1] != "neutral" && counter[4] < 0: #attacked counter depleted
			behavior[1] = "neutral"
		
		if isPlayerInRange: #reset detection counter due to player in range
			counter[5] = getCooldown(5)
		elif behavior[0] != "neutral" && counter[5] < 0: #detection counter depleted
			behavior[0] = "neutral"
		
		#the attacked behavior takes precedence over detection
		var behav = behavior[1]
		if behav == "neutral":
			behav = behavior[0]
		
		match behav:
			"neutral": #idle or move randomly
				if behavior[2] != "neutral": #newly neutral
					counter[3] = getCooldown(3)
					animationPlayer.play("idle")
				elif animationPlayer.current_animation == "idle": #not currently doing anything
					if counter[3] < 0: 
						prepMove("neutral", "random")
			"aggressive": #attack or move closer
				if isPlayerInRange && (animationPlayer.current_animation == "idle" || animationPlayer.current_animation == "move"):
					if counter[2] < 0: #can attack
						if counter[1] < 0: #can attack2
							animationPlayer.play(getAnimationName("attack2"))
							animationPlayer.queue("idle")
							counter[1] = getCooldown(1)
							counter[2] = getCooldown(2)
						elif counter[0] < 0: #can attack1
							animationPlayer.play(getAnimationName("attack1"))
							animationPlayer.queue("idle")
							counter[0] = getCooldown(0)
							counter[2] = getCooldown(2)
				elif animationPlayer.current_animation == "idle":
					prepMove("aggressive", "player")
			"curious":
				pass
			"scared":
				pass
			

func die():
	dead = true
	animationPlayer.play("die")
	print(str("enemy died and dropped: ", getDrops()))

func pickup():
	#destroy
	queue_free()
	return getDrops()

func prepMove(speedType, target):
	match target:
		"random":
			moveGoal = randomLocation(position, 100)
			#while true:
				#if moveGoal is within the allowed space, break
		"player":
			moveGoal = playerNode.global_position
	distanceToCover = position.distance_to(moveGoal)
	if distanceToCover > 50:
		distanceToCover = 50
	speed = getSpeed(speedType)
	animationPlayer.play("move")

func randomLocation(start, distance):
	var rng = RandomNumberGenerator.new()
	var rn = rng.randf_range(0,1)
	var newX = start.x + (rn-0.5) * distance
	rn = rng.randf_range(0,1)
	var newY = start.y + (rn-0.5) * distance
	var location = Vector2(newX, newY)
	return location

func _player_detected(area):
	behavior[0] = getBehavior("detection")
	playerNode = area.get_parent()
	counter[5] = getCooldown(5)
func _player_undetected(_area):
	behavior[0] = "neutral"

func _on_attack_radius_area_entered(_area):
	isPlayerInRange = true
func _on_attack_radius_area_exited(_area):
	isPlayerInRange = false

func setData(givenData):
	print("setting enemy variables...")
	print(givenData)
	#unpack data
	data = givenData
	data["speed"] = unpackData(data["speed"], 1)
	data["defense"] = unpackData(data["defense"], 1.0)
	data["animation_name"] = unpackData(data["animation_name"], "str")
	data["damage"] = unpackData(data["damage"], 1)
	data["cooldown"] = unpackData(data["cooldown"], 1)
	data["drop_item_id"] = unpackData(data["drop_item_id"], 1)
	data["drop_chance"] = unpackData(data["drop_chance"], 1.0)
	data["damage_type"] = unpackData(data["damage_type"], "str")
	#apply data
	stats.setHealth(data["health"])
	stats.setDefs(data["defense"])
	stats.setDmgs(data["damage"])
	$Hitboxes.setDamageTypes(data["damage_type"])
	$DetectionRadius/CollisionShape2D.shape.radius = getDetectionRadius()
	var reso = load(str("res://Assets/Ingame/Enemies/", getFilename(), ".tres"))
	$AnimatedSprite2D.set_sprite_frames(reso)

func getID():
	return data["enemy_id"]
func getName():
	return data["name"]
func getFilename():
	return data["filename"]
func getMaxHealth():
	return data["health"]
func getSpeed(mode):
	match mode:
		"neutral":
			return data["speed"][0]
		"aggressive":
			return data["speed"][1]
		"curious":
			return data["speed"][2]
		"scared":
			return data["speed"][3]
func getAnimationName(attack):
	match attack:
		"attack1":
			return data["animation_name"][0]
		"attack2":
			return data["animation_name"][1]
func getCooldown(type):
	#attack1, attack2, attacks, actions, attacked, detected
	var cooldowns = [data["cooldown"][0], data["cooldown"][1], 3000, 2000, 10000, 5000] 
	return cooldowns[type]
func getDrops(): #returns array of item ids
	var drops = []
	var rng = RandomNumberGenerator.new()
	var rn = rng.randf_range(0,1)
	
	for i in data["drop_item_id"].size():
		if rn <= data["drop_chance"][i]:
			drops += [data["drop_item_id"][i]]
	return drops
func getDetectionRadius():
	return data["detection_radius"]
func getBehavior(mode):
	match mode:
		"detection":
			return data["detection_behavior"]
		"attacked":
			return data["attacked_behavior"]

func packData(nodeArr, parameters, delimiter = ";"): #returns a dictionary based on parameters
	#initialize dictionary
	var data = {} 
	for parameter in parameters: 
		data[parameter] = ""
	
	#add data
	for node in nodeArr: #for each node,
		var childData = node.getData() #get data.
		for parameter in parameters: #then for each parameter,
			if childData != null: #if there is data, 
				data[parameter] += str(childData[parameter]) #concat its data to all the data
			data[parameter] += delimiter #else just add the delimiter
	
	#remove extra delimiter from each parameter
	for parameter in parameters: 
		data[parameter] = data[parameter].left(-1)
	
	return data
func unpackData(str, exType, delimiter = ";"): #returns an array given a string and example type
	var packedArr = str.split(delimiter)
	var arr = []
	#convert the packed array to an int array
	for i in packedArr.size():
		if packedArr[i] == "": 
			arr += [null] #empty array slot
		else:
			if typeof(exType) == typeof(1): #int
				arr += [int(packedArr[i])] #int slot
			if typeof(exType) == typeof(1.0): #float
				arr += [float(packedArr[i])] #float slot
			if typeof(exType) == typeof("str"): #string
				arr += [String(packedArr[i])] #string slot
	return arr
