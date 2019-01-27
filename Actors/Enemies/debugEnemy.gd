extends "res://Actors/Enemies/baseEnemy.gd"

func _physics_process(delta):
	var inputVector = Vector2(0,0)
	
	if (Input.is_action_pressed("ui_left")):
		inputVector.x -= 1
	if (Input.is_action_pressed("ui_right")):
		inputVector.x += 1
	if (Input.is_action_pressed("ui_up")):
		inputVector.y -= 1
	if (Input.is_action_pressed("ui_down")):
		inputVector.y += 1
	
	move_and_collide(inputVector * 4)