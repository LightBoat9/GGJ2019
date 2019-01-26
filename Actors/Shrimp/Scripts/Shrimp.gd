extends KinematicBody2D

var target_position = null
onready var velocity = Vector2()

var acceleration = 2
var maxSpeed = 5
var minSpin = 0.05
var maxSpin = 0.25

func _ready():
	target_position = Vector2()
	minSpin += rand_range(-0.01,0.02)
	maxSpin += rand_range(-0.05,0.05)

func _physics_process(delta):
	velocity = velocity_to_target()
	velocity = velocity.clamped(maxSpeed)
	
	var velocityMag = velocity.distance_to(Vector2())
	
	rotation += lerp(minSpin, maxSpin, velocityMag/maxSpeed)
	
	move_and_collide(velocity)
	pass

func assign_target(var targ):
	target_position = targ
	update()

func velocity_to_target():
	if (target_position == null):
		pass
	
	var local_target = target_position - global_position
	var moveVect = local_target.normalized()
	
	var final = velocity + moveVect * acceleration
	final = final.clamped(local_target.distance_to(Vector2()))
	
	return final