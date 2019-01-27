extends "res://Actors/Enemies/baseEnemy.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum States{DEFAULT, PURSUING, ANTICIPATING, LUNGING}

var velocity = Vector2()
var target = null
var sightLimit_enter = 160
var sightLimit_exit = 192

var lungeLimit_enter = 80

var pursuitSpeed = 2
var lungeSpeed = 6

onready var anticipationTimer = $anticipationTimer
onready var lungeTimer = $lungeTimer
onready var sprite = $Sprite

onready var tex_default = load("res://Actors/Enemies/debugEnemy.png")
onready var tex_anticipation = load("res://Actors/Enemies/debugEnemy_anticipation.png")
onready var tex_lunge = load("res://Actors/Enemies/debugEnemy_lunge.png")

func _ready():
	state = States.DEFAULT

func _physics_process(delta):
	if (health>0):
		if (state == States.DEFAULT):
			_default_check()
		elif (state == States.PURSUING):
			if !_pursuing_check():
				_pursuit()
		elif (state == States.ANTICIPATING):
			_anticipate()
		
		move_and_slide(velocity/delta)

func _default_check():
	for node in get_tree().get_nodes_in_group("Players"):
		var dist = global_position.distance_to(node.global_position)
		
		if (dist<=sightLimit_enter):
			state = States.PURSUING
			target = node
			print("Targeting "+str(node))
			break

func _pursuing_check():
	var dist = global_position.distance_to(target.global_position)
	
	if (dist>sightLimit_exit):
		state = States.DEFAULT
		target = null
		velocity = Vector2()
		return true
	elif (dist<=lungeLimit_enter):
		velocity = Vector2()
		state = States.ANTICIPATING
		sprite.texture = tex_anticipation
		anticipationTimer.start()
		return true
	
	return false

func _pursuit():
	var dir = (target.global_position-global_position).normalized()
	_set_image_angle(dir)
	velocity = dir * pursuitSpeed

func _lunge():
	var dir = (target.global_position-global_position).normalized()
	_set_image_angle(dir)
	velocity = dir * lungeSpeed
	state = States.LUNGING
	sprite.texture = tex_lunge
	lungeTimer.start()

func _anticipate():
	var dir = (target.global_position-global_position).normalized()
	_set_image_angle(dir)

func _lungeStop():
	velocity = Vector2()
	state = States.PURSUING
	sprite.texture = tex_default

func _set_image_angle(var dir):
	var angle = rad2deg(dir.angle())
	
	sprite.rotation_degrees = angle
	if (angle>90 || angle <=-90):
		sprite.flip_v = true
	else:
		sprite.flip_v = false