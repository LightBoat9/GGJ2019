extends "res://Actors/Enemies/baseEnemy.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum States{DEFAULT, PURSUING, ANTICIPATING, LUNGING}

var velocity = Vector2()
var dir = Vector2(1,0)
var target = null
var sightLimit_enter = 160
var sightLimit_exit = 192

var lungeLimit_enter = 112

var pursuitSpeed = 2
var lungeSpeed = 6

onready var anticipationTimer = $anticipationTimer
onready var lungeTimer = $lungeTimer
onready var sprite = $Sprite
onready var biteCollider = $Sprite/Area2D
var maxEats = 5
var eatRange = []

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

func _die():
	._die()
	
	anticipationTimer.stop()
	lungeTimer.stop()
	
	velocity = Vector2()

func _default_check():
	for node in get_tree().get_nodes_in_group("Players"):
		var dist = global_position.distance_to(node.global_position)
		
		if (dist<=sightLimit_enter):
			state = States.PURSUING
			target = node
			
			if (!target.is_connected("ImDead",self,"_targetIsDead")):
				target.connect("ImDead",self,"_targetIsDead")
			
			#print("Targeting "+str(node))
			break

func _pursuing_check():
	if (target == null):
		state = States.DEFAULT
		velocity = Vector2()
		return true
	
	var dist = global_position.distance_to(target.global_position)
	
	if (dist>sightLimit_exit):
		state = States.DEFAULT
		if (target.is_connected("ImDead",self,"_targetIsDead")):
				target.disconnect("ImDead",self,"_targetIsDead")
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
	dir = (target.global_position-global_position).normalized()
	_set_image_angle(dir)
	velocity = dir * pursuitSpeed

func _lunge():
	if (target != null):
		dir = (target.global_position-global_position).normalized()
		_set_image_angle(dir)
	
	velocity = dir * lungeSpeed
	state = States.LUNGING
	sprite.texture = tex_lunge
	lungeTimer.start()

func _anticipate():
	if (target != null):
		dir = (target.global_position-global_position).normalized()
		_set_image_angle(dir)

func _lungeStop():
	eatRange.resize(min(eatRange.size(),maxEats))
	
	for eat in eatRange:
		#kill shrimpies
		
		if (eat.is_in_group("Shrimp")):
			eat.kill_shrimp(dir)
		
		pass
	
	velocity = Vector2()
	state = States.PURSUING
	sprite.texture = tex_default
	
	eatRange.clear()

func _set_image_angle(var dir):
	var angle = rad2deg(dir.angle())
	
	sprite.rotation_degrees = angle
	if (angle>90 || angle <=-90):
		sprite.flip_v = true
	else:
		sprite.flip_v = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("Players") and eatRange.find(body) == -1:
		eatRange.append(body)

func _on_Area2D_body_exited(body):
	var index = eatRange.find(body)
	
	if (index!=-1):
		eatRange.remove(index)

func _targetIsDead():
	if (target != null && target.is_connected("ImDead",self,"_targetIsDead")):
		target.disconnect("ImDead",self,"_targetIsDead")
	target = null
