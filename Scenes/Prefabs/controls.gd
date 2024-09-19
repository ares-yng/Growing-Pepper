extends Control

#Up, Down, Left, Right
@onready var spriteNodes = []
@onready var keyNodes = []
@onready var labelNodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 4:
		spriteNodes += [get_child(i)]
		keyNodes += [spriteNodes[i].get_child(0)]
		labelNodes += [spriteNodes[i].get_child(1)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		spriteNodes[0].frame += 4
	elif Input.is_action_just_released("ui_up"):
		spriteNodes[0].frame -= 4
	if Input.is_action_just_pressed("ui_down"):
		spriteNodes[1].frame += 4
	elif Input.is_action_just_released("ui_down"):
		spriteNodes[1].frame -= 4
	if Input.is_action_just_pressed("ui_left"):
		spriteNodes[2].frame += 4
	elif Input.is_action_just_released("ui_left"):
		spriteNodes[2].frame -= 4
	if Input.is_action_just_pressed("ui_right"):
		spriteNodes[3].frame += 4
	elif Input.is_action_just_released("ui_right"):
		spriteNodes[3].frame -= 4
		
