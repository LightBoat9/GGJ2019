extends KinematicBody2D

const DeathParticles = preload('res://Actors/Shrimp/DeathParticles.tscn')

var target_position = null
var velocity = Vector2()

var acceleration = 2
var maxSpeed = 8
var launchSpeed = 12
var minSpin = 0.05
var maxSpin = 0.25

var swarmDamage = 0.1
var launchDamage = 0.25

var enemy_touching
var shrimp_cursor = null

enum States { DEFAULT, LAUNCHING } 
var state = States.DEFAULT

onready var area = $Area2D
onready var attack_timer = $AttackTimer

func _ready():
	add_to_group("Players")
	
	if not area.is_connected('body_entered', self, '_body_entered'):
		area.connect('body_entered', self, '_body_entered')
		
	if not area.is_connected('body_exited', self, '_body_exited'):
		area.connect('body_exited', self, '_body_exited')
	target_position = Vector2()
	minSpin += rand_range(-0.01,0.02)
	maxSpin += rand_range(-0.05,0.05)

func _process(delta):
	if enemy_touching and attack_timer.time_left == 0 and Input.is_mouse_button_pressed(BUTTON_RIGHT):
		enemy_touching.shrimpInteract(swarmDamage)
		attack_timer.start()

func _physics_process(delta):
	if (state == States.LAUNCHING):
		_launch_update()
	else:
		velocity = velocity_to_target()
		velocity = velocity.clamped(maxSpeed)
	
	var velocityMag = velocity.distance_to(Vector2())
	
	rotation += lerp(minSpin, maxSpin, velocityMag/maxSpeed)
	
	move_and_slide(velocity/delta)
	if (state == States.LAUNCHING && get_slide_count()>0):
		var slideCollide = get_slide_collision(get_slide_count()-1)
		
		if (slideCollide != null):
			var collider = slideCollide.collider
			
			if collider.get_collision_layer_bit(0):
				kill_shrimp()
				print("Cool")
				_return_to_cursor()
	
	
	pass

func assign_target(var targ):
	target_position = targ
	update()
	
func kill_shrimp(anglev=Vector2()):
	var inst = DeathParticles.instance()
	inst.global_position = global_position
	inst.rotation = anglev.angle()
	get_parent().add_child(inst)
	
	
	if self in shrimp_cursor.shrimp:
		shrimp_cursor.remove_shrimp(shrimp_cursor.shrimp.find(self))
		
	shrimp_cursor = null
		
	queue_free()

func velocity_to_target():
	if (state == States.LAUNCHING):
		return velocity
	
	var local_target = target_position - global_position
	var moveVect = local_target.normalized()
	
	var final = velocity + moveVect * acceleration
	
	var distanceMag = local_target.distance_to(Vector2())
	var projection = 0 if (distanceMag == 0) else final.dot(local_target)/distanceMag
	var finalClamp = min(projection,distanceMag)
	
	return final.clamped(0 if (finalClamp < 0.01) else finalClamp)

func launch(var to):
	var launchDirection = to - global_position
	velocity = launchDirection.normalized() * launchSpeed
	target_position = to
	state = States.LAUNCHING

func _launch_update():
	var to_target = target_position - global_position
	var targetMag = to_target.distance_to(Vector2())
	
	var targetProjection = 0 if (targetMag == 0) else velocity.dot(to_target)/targetMag
	
	if (targetProjection<=0):
		print("projection return")
		_return_to_cursor()

func _return_to_cursor():
	if (shrimp_cursor != null):
		shrimp_cursor.add_shrimp_existing(self)
		state = States.DEFAULT

func _body_entered(body):
	if body.is_in_group('Enemies'):
		enemy_touching = body
		
		if (state == States.LAUNCHING):
			enemy_touching.shrimpInteract(launchDamage)
			_return_to_cursor()

func _body_exited(body):
	if body.is_in_group('Enemies'):
		enemy_touching = null