extends Node2D

@onready var timeLabel = $Time

var time = 0 
var displayTime = -10000

func _physics_process(delta):
	time += delta*1000
	if time >= displayTime + 10000:
		displayTime += 10000
		if time >= 1440000:
			time -= 1440000
			displayTime -= 1440000
			print("day change")
		
		var hour = str(displayTime/60000)
		if hour.length() == 1:
			hour = str("0", hour)
			
		var mins = str(displayTime%60000).left(1)
		mins = str(mins, "0")
		
		timeLabel.text = str(hour, ":", mins)

func getTime():
	return int(time)
func setTime(t): #accepts an int or float, or season
	#wake up time per season
	if typeof(t) == typeof(""):
		match t:
			"spring": #6am
				t = 360000
			"summer": #5am
				t = 300000
			"autumn": #6am
				t = 360000
			"winter": #7am
				t = 420000
	
	time = float(t)
	displayTime = int(t/10000) * 10000 - 10000
