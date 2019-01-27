extends "res://Actors/Enemies/baseEnemy.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum States{DEFAULT, PURSUING, ANTICIPATING, LUNGING}

var state = States.DEFAULT

func _process():
	
	
	pass