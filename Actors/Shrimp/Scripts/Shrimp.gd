extends KinematicBody2D

var target_position = null
var velocity = Vector2()

var acceleration = 2
var maxSpeed = 8
var minSpin = 0.05
var maxSpin = 0.25

var enemy_touching

enum States { DEFAULT, ATACKING } 
var state = States.DEFAULT

onready var area = $Area2D
onready var attack_timer = $AttackTimer

func _ready():
	if not area.is_connected('body_entered', self, '_body_entered'):
		area.connect('body_entered', self, '_body_entered')
		
	if not area.is_connected('body_exited', self, '_body_exited'):
		area.connect('body_exited', self, '_body_exited')
	target_position = Vector2()
	minSpin += rand_range(-0.01,0.02)
	maxSpin += rand_range(-0.05,0.05)

func _process(delta):
	if enemy_touching and attack_timer.time_left == 0:
		enemy_touching.shrimpInteract(0.1)
		attack_timer.start()

func _physics_process(delta):
	velocity = velocity_to_target()
	velocity = velocity.clamped(maxSpeed)
	
	var velocityMag = velocity.distance_to(Vector2())
	
	rotation += lerp(minSpin, maxSpin, velocityMag/maxSpeed)
	
	move_and_slide(velocity/delta)
	pass

func assign_target(var targ):
	target_position = targ
	update()

func velocity_to_target():
	if (target_position == null):
		return velocity
	
	var local_target = target_position - global_position
	var moveVect = local_target.normalized()
	
	var final = velocity + moveVect * acceleration
	
	var distanceMag = local_target.distance_to(Vector2())
	var projection = 0 if (distanceMag == 0) else final.dot(local_target)/distanceMag
	var finalClamp = min(projection,distanceMag)
	
	return final.clamped(0 if (finalClamp < 0.01) else finalClamp)
	
func _body_entered(body):
	if body.is_in_group('Enemies'):
		enemy_touching = body

func _body_exited(body):
	if body.is_in_group('Enemies'):
		enemy_touching = null