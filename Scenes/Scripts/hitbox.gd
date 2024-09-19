extends Node2D

var damageTypes = ["physical", "physical", "physical"] #touch, attack1, attack2

func setDamageTypes(dmgTypes):
	damageTypes = dmgTypes

func hit(area, attack, type):
	print(str(get_parent().name, " hits ", area.get_parent().name))
	#get dmg
	var parent = get_parent()
	if !parent.has_node("Stats"):
		parent = parent.get_parent()
	var dmg = parent.get_node("Stats").getDmg(attack)
	#apply dmg
	area.hurt(dmg, type, get_parent())

func _on_area_entered(area):
	area.hurt(1, "physical", get_parent())

func _touch(area):
	hit(area, "touch", damageTypes[0])

func _attack1(area):
	hit(area, "attack1", damageTypes[1])

func _attack2(area):
	hit(area, "attack2", damageTypes[2])
