extends Node2D

var wasHurt = false
var wasHurtBy #tracks what hit it

@export var health = 1
@export var damages = [1,1,1] #touch, attack1, attack2
@export var defenses = [1,1,1,1,1] #physical, fire, water, growth, decay

func takeDamage(dmg, type = "physical", obj = null):
	var reduction = 1 - getDef(type)
	health -= int(dmg*reduction)
	wasHurt = true
	wasHurtBy = obj

func getDmg(type):
	match type:
		"touch":
			return damages[0]
		"attack1":
			return damages[1]
		"attack2":
			return damages[2]
func getDef(type):
	match type:
		"physical":
			return defenses[0]
		"fire":
			return defenses[1]
		"water":
			return defenses[2]
		"growth":
			return defenses[3]
		"decay":
			return defenses[4]

func setHealth(hp):
	health = hp
func setDefs(defs):
	defenses = defs
func setDmgs(dmgs):
	damages = dmgs
