extends Area2D

func hurt(dmg, type, parent):
	print(str(get_parent().name, " was hurt by ", parent.name, ". the damage was: ", dmg))
	get_parent().get_node("Stats").takeDamage(dmg, type, parent)
