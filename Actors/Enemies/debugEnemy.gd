extends "res://Actors/Enemies/baseEnemy.gd"

func _ready():
	print(self.is_in_group("Enemies"))
	
	._ready()

func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		_takeDamage(1)
	
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