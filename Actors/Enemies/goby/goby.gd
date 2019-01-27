extends "res://Actors/Enemies/baseEnemy.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum States{DEFAULT, PURSUING, ANTICIPATING, LUNGING}

var velocity = Vector2()
var target = null
var sightLimit_enter = 64
var sightLimit_exit = 96

func _ready():
	state = States.DEFAULT
	print("ready")
	_default_check()

func _process():
	if (state == States.DEFAULT):
		_default_check()
	elif (state == States.PURSUING):
		pass
	
	pass

func _default_check():
	for node in get_tree().get_nodes_in_group("Players"):
		var dist = global_position.distance_to(node.global_position)
		
		if (dist<=sightLimit_enter):
			state = States.PURSUING
			target = node
			break

func _pursuing_check():